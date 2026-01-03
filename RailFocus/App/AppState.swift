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

    /// Currently selected tab
    var selectedTab: AppTab = .home

    /// Whether a journey is currently in progress
    var isJourneyActive: Bool = false

    /// Current journey ID if active
    var activeJourneyId: UUID?

    /// Show the ride mode full screen cover
    var showRideMode: Bool = false

    /// Navigation path for programmatic navigation
    var navigationPath = NavigationPath()

    init() {}

    // MARK: - Actions

    func startJourney(id: UUID) {
        activeJourneyId = id
        isJourneyActive = true
        showRideMode = true
    }

    func endJourney() {
        showRideMode = false
        isJourneyActive = false
        activeJourneyId = nil
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

// MARK: - App Tabs

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case logs
    case insights
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Journey"
        case .logs: return "Logs"
        case .insights: return "Insights"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "tram.fill"
        case .logs: return "list.bullet"
        case .insights: return "chart.bar.fill"
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
