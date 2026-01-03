//
//  MainTabView.swift
//  RailFocus
//
//  Main tab-based navigation container
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.appState) private var appState
    @Environment(\.theme) private var theme

    var body: some View {
        TabView(selection: Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            LogsView()
                .tabItem {
                    Label(AppTab.logs.title, systemImage: AppTab.logs.icon)
                }
                .tag(AppTab.logs)

            InsightsView()
                .tabItem {
                    Label(AppTab.insights.title, systemImage: AppTab.insights.icon)
                }
                .tag(AppTab.insights)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
        .tint(theme.accentStyle.color)
        .fullScreenCover(isPresented: Binding(
            get: { appState.showRideMode },
            set: { appState.showRideMode = $0 }
        )) {
            RideModeView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.appState, AppState())
        .environment(\.theme, Theme.shared)
}
