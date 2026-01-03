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
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.appState, AppState())
        .environment(\.theme, Theme.shared)
}
