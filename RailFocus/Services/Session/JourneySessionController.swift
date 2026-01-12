//
//  JourneySessionController.swift
//  RailFocus
//
//  State machine and progress engine for train journey focus sessions.
//  Handles phase transitions, easing curves, and station milestones.
//

import Foundation
import SwiftUI
import Combine
import UIKit

// MARK: - Journey Phase
// State machine for journey progression
// Transitions: setup → ticketRipping → boarding → departing → cruising → approaching → arrived

enum JourneyPhase: String, CaseIterable {
    case setup              // Initial state, preparing journey
    case ticketRipping      // User is ripping ticket (pre-boarding)
    case boarding           // 0-3%: Doors closing, settling in
    case departing          // 3-12%: Acceleration, leaving station
    case cruising           // 12-85%: Steady travel, passing stations
    case approaching        // 85-97%: Deceleration, destination in sight
    case arrived            // 97-100%: Journey complete
    case paused             // Timer paused by user
    case interrupted        // App backgrounded
    case cancelled          // User ended early

    var displayText: String {
        switch self {
        case .setup: return "Preparing"
        case .ticketRipping: return "Punch your ticket"
        case .boarding: return "Boarding"
        case .departing: return "Departing"
        case .cruising: return "At speed"
        case .approaching: return "Approaching destination"
        case .arrived: return "Arrived"
        case .paused: return "Paused"
        case .interrupted: return "Returning..."
        case .cancelled: return "Journey ended"
        }
    }

    var announcement: String? {
        switch self {
        case .boarding: return "Doors closing — settle in."
        case .departing: return "We're on our way. Stay focused."
        case .cruising: return "Smooth ride — keep going."
        case .approaching: return "Final stretch — almost there."
        case .arrived: return "You've arrived. Well done."
        case .interrupted: return "Welcome back — continuing our journey."
        default: return nil
        }
    }
}

// MARK: - Station Milestone

struct StationMilestone: Identifiable {
    let id = UUID()
    let name: String
    let progressPosition: Double // 0.0 to 1.0
    var isPassed: Bool = false
}

// MARK: - Journey Session Controller

@Observable
final class JourneySessionController {

    // MARK: - State Properties

    private(set) var phase: JourneyPhase = .setup
    private(set) var progress: Double = 0.0 // 0.0 to 1.0, always monotonically increasing
    private(set) var displayProgress: Double = 0.0 // Eased progress for visuals
    private(set) var stations: [StationMilestone] = []
    private(set) var currentStationIndex: Int = 0
    private(set) var isInTunnel: Bool = false

    // Time tracking
    private(set) var totalDuration: TimeInterval = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var startTime: Date?

    // Speed multiplier (reduced when backgrounded)
    private var speedMultiplier: Double = 1.0
    private let backgroundSpeedMultiplier: Double = 0.85

    // Internal
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: CFTimeInterval = 0
    private var backgroundDate: Date?
    private var announcementQueue: [String] = []

    // Callbacks
    var onPhaseChange: ((JourneyPhase) -> Void)?
    var onStationPassed: ((StationMilestone) -> Void)?
    var onAnnouncement: ((String) -> Void)?
    var onTunnelEnter: (() -> Void)?
    var onTunnelExit: (() -> Void)?
    var onComplete: (() -> Void)?

    // MARK: - Computed Properties

    var timeRemaining: TimeInterval {
        max(0, totalDuration - elapsedTime)
    }

    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var nextStation: StationMilestone? {
        stations.first { !$0.isPassed }
    }

    var passedStationCount: Int {
        stations.filter { $0.isPassed }.count
    }

    var isActive: Bool {
        switch phase {
        case .boarding, .departing, .cruising, .approaching:
            return true
        default:
            return false
        }
    }

    // MARK: - Initialization

    init() {
        setupNotificationObservers()
    }

    deinit {
        stopDisplayLink()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Configure journey with duration and generate stations
    func configure(duration: TimeInterval, originName: String, destinationName: String) {
        totalDuration = duration
        elapsedTime = 0
        progress = 0
        displayProgress = 0
        speedMultiplier = 1.0

        // Generate stations based on duration
        // Formula: ~1 station per 5 minutes, minimum 3, maximum 12
        let stationCount = min(12, max(3, Int(duration / 300) + 2))
        stations = generateStations(count: stationCount, origin: originName, destination: destinationName)
        currentStationIndex = 0

        transitionTo(.setup)
    }

    /// Begin ticket ripping phase
    func beginTicketRipping() {
        transitionTo(.ticketRipping)
    }

    /// Complete ticket ripping and start boarding
    func completeTicketRipping() {
        transitionTo(.boarding)

        // Start the journey after a brief boarding delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.startJourney()
        }
    }

    /// Start the actual journey timer
    func startJourney() {
        startTime = Date()
        startDisplayLink()
        transitionTo(.departing)
    }

    /// Pause the journey
    func pause() {
        guard isActive else { return }
        stopDisplayLink()
        transitionTo(.paused)
    }

    /// Resume from pause
    func resume() {
        guard phase == .paused || phase == .interrupted else { return }
        startDisplayLink()

        // Determine correct phase based on progress
        let activePhase = phaseForProgress(progress)
        transitionTo(activePhase)

        if phase == .interrupted {
            queueAnnouncement("Welcome back — continuing our journey.")
        }
    }

    /// End journey early
    func endEarly() {
        stopDisplayLink()
        transitionTo(.cancelled)
    }

    /// Reset controller
    func reset() {
        stopDisplayLink()
        phase = .setup
        progress = 0
        displayProgress = 0
        elapsedTime = 0
        totalDuration = 0
        stations = []
        currentStationIndex = 0
        isInTunnel = false
        speedMultiplier = 1.0
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
        lastUpdateTime = CACurrentMediaTime()
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateProgress() {
        guard isActive || phase == .boarding else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update elapsed time with speed multiplier
        elapsedTime += deltaTime * speedMultiplier
        elapsedTime = min(elapsedTime, totalDuration)

        // Calculate raw progress (always monotonically increasing)
        let rawProgress = totalDuration > 0 ? elapsedTime / totalDuration : 0
        progress = max(progress, min(1.0, rawProgress)) // Never decrease

        // Apply easing for visual progress
        displayProgress = applyEasing(progress)

        // Check phase transitions
        updatePhaseForProgress()

        // Check station milestones
        checkStationMilestones()

        // Check tunnel events
        checkTunnelEvents()

        // Check completion
        if progress >= 1.0 {
            complete()
        }
    }

    // MARK: - Easing

    /// Apply motion easing based on journey phase
    /// - Departing: ease-in (acceleration)
    /// - Cruising: linear
    /// - Approaching: ease-out (deceleration)
    private func applyEasing(_ rawProgress: Double) -> Double {
        let phase = phaseForProgress(rawProgress)

        switch phase {
        case .boarding:
            // Very slow start
            return rawProgress * 0.3

        case .departing:
            // Ease-in: acceleration (3% to 12%)
            let localProgress = (rawProgress - 0.03) / 0.09
            let eased = localProgress * localProgress // Quadratic ease-in
            return 0.03 + eased * 0.09

        case .cruising:
            // Linear steady motion
            return rawProgress

        case .approaching:
            // Ease-out: deceleration (85% to 97%)
            let localProgress = (rawProgress - 0.85) / 0.12
            let eased = 1 - pow(1 - localProgress, 2) // Quadratic ease-out
            return 0.85 + eased * 0.12

        case .arrived:
            return 1.0

        default:
            return rawProgress
        }
    }

    // MARK: - Phase Management

    private func phaseForProgress(_ progress: Double) -> JourneyPhase {
        switch progress {
        case 0..<0.03: return .boarding
        case 0.03..<0.12: return .departing
        case 0.12..<0.85: return .cruising
        case 0.85..<0.97: return .approaching
        case 0.97...1.0: return .arrived
        default: return .cruising
        }
    }

    private func updatePhaseForProgress() {
        guard isActive else { return }

        let newPhase = phaseForProgress(progress)
        if newPhase != phase && newPhase != .paused && newPhase != .interrupted {
            transitionTo(newPhase)
        }
    }

    private func transitionTo(_ newPhase: JourneyPhase) {
        guard newPhase != phase else { return }

        let oldPhase = phase
        phase = newPhase

        // Trigger announcement for new phase
        if let announcement = newPhase.announcement {
            queueAnnouncement(announcement)
        }

        // Phase-specific haptics
        triggerPhaseHaptic(newPhase)

        onPhaseChange?(newPhase)

        // Debug logging
        #if DEBUG
        print("Journey phase: \(oldPhase.rawValue) → \(newPhase.rawValue)")
        #endif
    }

    // MARK: - Station Milestones

    private func generateStations(count: Int, origin: String, destination: String) -> [StationMilestone] {
        var milestones: [StationMilestone] = []

        // Station names for variety
        let intermediateNames = [
            "Riverside", "Valley View", "Summit", "Meadowbrook",
            "Harbor Point", "Lakeside", "Pine Ridge", "Oak Grove",
            "Cedar Falls", "Maple Heights", "Willow Creek", "Stone Bridge"
        ].shuffled()

        // Origin at 0%
        milestones.append(StationMilestone(name: origin, progressPosition: 0.0, isPassed: true))

        // Intermediate stations evenly distributed between 15% and 85%
        let intermediateCount = count - 2
        if intermediateCount > 0 {
            let spacing = 0.70 / Double(intermediateCount + 1)
            for i in 1...intermediateCount {
                let position = 0.15 + spacing * Double(i)
                let name = intermediateNames[i - 1]
                milestones.append(StationMilestone(name: name, progressPosition: position))
            }
        }

        // Destination at 100%
        milestones.append(StationMilestone(name: destination, progressPosition: 1.0))

        return milestones
    }

    private func checkStationMilestones() {
        for i in 0..<stations.count {
            if !stations[i].isPassed && progress >= stations[i].progressPosition {
                stations[i].isPassed = true
                currentStationIndex = i

                // Don't announce origin (already passed) or destination (handled by arrived phase)
                if i > 0 && i < stations.count - 1 {
                    queueAnnouncement("Passing \(stations[i].name)")
                    onStationPassed?(stations[i])
                    triggerStationHaptic()
                }
            }
        }
    }

    // MARK: - Tunnel Events

    private func checkTunnelEvents() {
        // Trigger tunnels at ~35% and ~70%
        let tunnelPositions: [Double] = [0.35, 0.70]
        let tunnelThreshold: Double = 0.02

        for tunnelPos in tunnelPositions {
            let distance = abs(progress - tunnelPos)

            if distance < tunnelThreshold && !isInTunnel {
                enterTunnel()
            } else if distance >= tunnelThreshold && isInTunnel && progress > tunnelPos {
                exitTunnel()
            }
        }
    }

    private func enterTunnel() {
        isInTunnel = true
        onTunnelEnter?()
        HapticsEngine.shared.playTunnelEnter()
    }

    private func exitTunnel() {
        isInTunnel = false
        onTunnelExit?()
    }

    // MARK: - Completion

    private func complete() {
        stopDisplayLink()
        transitionTo(.arrived)

        // Mark destination as passed
        if let lastIndex = stations.indices.last {
            stations[lastIndex].isPassed = true
        }

        HapticsEngine.shared.playCompletion()
        onComplete?()
    }

    // MARK: - Announcements

    private func queueAnnouncement(_ message: String) {
        onAnnouncement?(message)
    }

    // MARK: - Haptics

    private func triggerPhaseHaptic(_ phase: JourneyPhase) {
        switch phase {
        case .boarding:
            HapticsEngine.shared.playBoardingVibration()
        case .departing:
            HapticsEngine.shared.playDeparture()
        case .arrived:
            HapticsEngine.shared.playCompletion()
        default:
            break
        }
    }

    private func triggerStationHaptic() {
        HapticsEngine.shared.playStationPass()
    }

    // MARK: - Background Handling

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        guard isActive else { return }
        backgroundDate = Date()
        speedMultiplier = backgroundSpeedMultiplier
        transitionTo(.interrupted)
    }

    @objc private func appWillEnterForeground() {
        guard phase == .interrupted, let backgroundDate = backgroundDate else { return }

        let elapsed = Date().timeIntervalSince(backgroundDate)
        self.backgroundDate = nil

        // Apply elapsed time with reduced speed
        elapsedTime += elapsed * backgroundSpeedMultiplier
        elapsedTime = min(elapsedTime, totalDuration)

        // Restore normal speed
        speedMultiplier = 1.0

        // Resume
        resume()
    }
}

// MARK: - Haptics Engine Protocol & Implementation

protocol HapticsEngineProtocol {
    func playTicketRip()
    func playBoardingVibration()
    func playDeparture()
    func playStationPass()
    func playTunnelEnter()
    func playCompletion()
}

final class HapticsEngine: HapticsEngineProtocol {
    static let shared = HapticsEngine()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        // Prepare generators
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    func playTicketRip() {
        heavyGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.mediumGenerator.impactOccurred()
        }
    }

    func playBoardingVibration() {
        // Subtle rumble sequence
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.lightGenerator.impactOccurred()
            }
        }
    }

    func playDeparture() {
        mediumGenerator.impactOccurred()
    }

    func playStationPass() {
        selectionGenerator.selectionChanged()
    }

    func playTunnelEnter() {
        lightGenerator.impactOccurred()
    }

    func playCompletion() {
        notificationGenerator.notificationOccurred(.success)
    }
}

// MARK: - Sound Engine Protocol (Stub)

protocol SoundEngineProtocol {
    func playTicketRip()
    func playDoorClose()
    func playTrainDepart()
    func playStationChime()
    func playTunnelWhoosh()
    func playArrivalChime()
    func setAmbientVolume(_ volume: Float)
}

final class SoundEngine: SoundEngineProtocol {
    static let shared = SoundEngine()

    private init() {}

    func playTicketRip() {
        // TODO: Play paper rip sound
    }

    func playDoorClose() {
        // TODO: Play door closing sound
    }

    func playTrainDepart() {
        // TODO: Play departure whistle/chime
    }

    func playStationChime() {
        // TODO: Play station pass chime
    }

    func playTunnelWhoosh() {
        // TODO: Play tunnel whoosh sound
    }

    func playArrivalChime() {
        // TODO: Play arrival celebration sound
    }

    func setAmbientVolume(_ volume: Float) {
        // TODO: Adjust ambient train sounds
    }
}
