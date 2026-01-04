//
//  ContentView.swift
//  RailFocus
//
//  Created by Harold S on 1/3/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appState) private var appState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainContainerView()
            } else {
                NewOnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Container View

struct MainContainerView: View {
    @Environment(\.appState) private var appState

    var body: some View {
        ZStack {
            // Current screen based on menu selection
            switch appState.selectedMenuItem {
            case .home:
                NewHomeView()
            case .inProgress:
                InProgressView()
            case .history:
                HistoryView()
            case .trends:
                TrendsView()
            case .settings:
                NewSettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.selectedMenuItem)
    }
}

// MARK: - In Progress View (placeholder)

struct InProgressView: View {
    @Environment(\.appState) private var appState

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let journey = appState.journeyRepository.inProgressJourney {
                    // Show in-progress journey
                    VStack(spacing: 24) {
                        Text("Journey In Progress")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        CompactBoardingPass(journey: journey)
                            .padding(.horizontal, 24)

                        Button {
                            appState.showRideMode = true
                        } label: {
                            Text("Return to Ride")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                )
                        }
                        .padding(.horizontal, 24)
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "tram.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.white.opacity(0.3))

                        Text("No Active Journey")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Start a new journey from the home screen")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.5))

                        Button {
                            appState.selectedMenuItem = .home
                        } label: {
                            Text("Go to Home")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.rfElectricBlue)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("In Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.selectedMenuItem = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.appState, AppState())
        .environment(\.theme, Theme.shared)
}
