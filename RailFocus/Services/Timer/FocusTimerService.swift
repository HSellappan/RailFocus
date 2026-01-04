//
//  FocusTimerService.swift
//  RailFocus
//
//  Focus timer engine for managing journey sessions
//

import Foundation
import Combine
import UserNotifications

// MARK: - Timer State

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case completed
    case interrupted
}

// MARK: - Focus Timer Service

@Observable
final class FocusTimerService {
    // MARK: - Properties

    private(set) var state: TimerState = .idle
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var totalDuration: TimeInterval = 0
    private(set) var elapsedTime: TimeInterval = 0

    private var timer: Timer?
    private var backgroundDate: Date?
    private var notificationScheduled = false

    // MARK: - Computed Properties

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return elapsedTime / totalDuration
    }

    var isActive: Bool {
        state == .running || state == .paused
    }

    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Init

    init() {
        setupNotificationObservers()
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    func start(duration: TimeInterval) {
        totalDuration = duration
        timeRemaining = duration
        elapsedTime = 0
        state = .running

        startTimer()
        scheduleCompletionNotification()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        timer?.invalidate()
        timer = nil
        cancelNotifications()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        startTimer()
        scheduleCompletionNotification()
    }

    func stop() {
        state = .interrupted
        timer?.invalidate()
        timer = nil
        cancelNotifications()
    }

    func reset() {
        state = .idle
        timeRemaining = 0
        totalDuration = 0
        elapsedTime = 0
        timer?.invalidate()
        timer = nil
        cancelNotifications()
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func tick() {
        guard state == .running else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
            elapsedTime += 1
        } else {
            complete()
        }
    }

    private func complete() {
        state = .completed
        timer?.invalidate()
        timer = nil
        triggerCompletionHaptic()
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
        guard state == .running else { return }
        backgroundDate = Date()
        timer?.invalidate()
        timer = nil
    }

    @objc private func appWillEnterForeground() {
        guard state == .running, let backgroundDate = backgroundDate else { return }

        let elapsed = Date().timeIntervalSince(backgroundDate)
        self.backgroundDate = nil

        if elapsed >= timeRemaining {
            timeRemaining = 0
            elapsedTime = totalDuration
            complete()
        } else {
            timeRemaining -= elapsed
            elapsedTime += elapsed
            startTimer()
        }
    }

    // MARK: - Notifications

    private func scheduleCompletionNotification() {
        guard !notificationScheduled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Journey Complete!"
        content.body = "You've arrived at your destination. Great focus session!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeRemaining,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "journey_complete",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        notificationScheduled = true
    }

    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["journey_complete"]
        )
        notificationScheduled = false
    }

    // MARK: - Haptics

    private func triggerCompletionHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
