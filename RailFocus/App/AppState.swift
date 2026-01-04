//
//  AppState.swift
//  RailFocus
//
//  Global application state management
//

import SwiftUI

// MARK: - App State

@Observable
final class AppState {
    /// Whether onboarding has been completed
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    /// Currently selected menu item
    var selectedMenuItem: MenuItem = .home

    /// Whether a journey is currently in progress
    var isJourneyActive: Bool = false

    /// Current journey if active
    var activeJourney: Journey?

    /// Show the ride mode full screen cover
    var showRideMode: Bool = false

    /// Show journey booking sheet
    var showBookingSheet: Bool = false

    /// Show arrival/completion screen
    var showArrivalScreen: Bool = false

    /// Services
    let timerService = FocusTimerService()
    let journeyRepository = JourneyRepository()
    let settings = UserSettings()

    init() {}

    // MARK: - Actions

    func startJourney(_ journey: Journey) {
        var newJourney = journey
        newJourney.start()
        activeJourney = newJourney
        journeyRepository.add(newJourney)
        isJourneyActive = true
        showRideMode = true
        timerService.start(duration: journey.scheduledDuration)
    }

    func completeJourney() {
        guard var journey = activeJourney else { return }
        journey.complete()
        journeyRepository.update(journey)
        timerService.reset()
        showRideMode = false
        showArrivalScreen = true
        isJourneyActive = false
        activeJourney = nil
    }

    func interruptJourney() {
        guard var journey = activeJourney else { return }
        journey.interrupt()
        journeyRepository.update(journey)
        timerService.reset()
        showRideMode = false
        isJourneyActive = false
        activeJourney = nil
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

// MARK: - Menu Items (Side Menu)

enum MenuItem: String, CaseIterable, Identifiable {
    case home
    case inProgress
    case history
    case trends
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .inProgress: return "In Progress"
        case .history: return "History"
        case .trends: return "Trends"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "globe.americas.fill"
        case .inProgress: return "tram.fill"
        case .history: return "clock.fill"
        case .trends: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Environment Key

private struct AppStateKey: EnvironmentKey {
    static let defaultValue = AppState()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
