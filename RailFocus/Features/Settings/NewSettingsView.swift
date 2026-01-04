//
//  NewSettingsView.swift
//  RailFocus
//
//  Settings screen with dark theme
//

import SwiftUI

struct NewSettingsView: View {
    @Environment(\.appState) private var appState
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Appearance section
                        SettingsSection(title: "Appearance") {
                            // Map style
                            NavigationLink {
                                MapStyleSettingsView()
                            } label: {
                                SettingsRow(
                                    icon: "map.fill",
                                    iconColor: .rfElectricBlue,
                                    title: "Map Style",
                                    value: appState.settings.mapStyle.displayName
                                )
                            }

                            // Labels toggle
                            SettingsToggleRow(
                                icon: "textformat",
                                iconColor: .orange,
                                title: "Map Labels",
                                isOn: Binding(
                                    get: { appState.settings.showLabels },
                                    set: { appState.settings.showLabels = $0 }
                                )
                            )
                        }

                        // Timer section
                        SettingsSection(title: "Timer") {
                            NavigationLink {
                                DurationSettingsView()
                            } label: {
                                SettingsRow(
                                    icon: "timer",
                                    iconColor: .rfEmerald,
                                    title: "Default Duration",
                                    value: "\(appState.settings.defaultDuration)m"
                                )
                            }
                        }

                        // Sounds section
                        SettingsSection(title: "Sounds & Feedback") {
                            SettingsToggleRow(
                                icon: "speaker.wave.2.fill",
                                iconColor: .purple,
                                title: "Ambient Sounds",
                                isOn: Binding(
                                    get: { appState.settings.ambientSoundsEnabled },
                                    set: { appState.settings.ambientSoundsEnabled = $0 }
                                )
                            )

                            SettingsToggleRow(
                                icon: "hand.tap.fill",
                                iconColor: .cyan,
                                title: "Haptic Feedback",
                                isOn: Binding(
                                    get: { appState.settings.hapticFeedbackEnabled },
                                    set: { appState.settings.hapticFeedbackEnabled = $0 }
                                )
                            )
                        }

                        // Notifications section
                        SettingsSection(title: "Notifications") {
                            SettingsToggleRow(
                                icon: "bell.fill",
                                iconColor: .rfWarning,
                                title: "Notifications",
                                isOn: Binding(
                                    get: { appState.settings.notificationsEnabled },
                                    set: { appState.settings.notificationsEnabled = $0 }
                                )
                            )
                        }

                        // Data section
                        SettingsSection(title: "Data") {
                            Button {
                                // Export data
                            } label: {
                                SettingsRow(
                                    icon: "square.and.arrow.up",
                                    iconColor: .rfElectricBlue,
                                    title: "Export Data",
                                    value: nil
                                )
                            }

                            Button {
                                showResetConfirmation = true
                            } label: {
                                SettingsRow(
                                    icon: "trash.fill",
                                    iconColor: .rfError,
                                    title: "Clear All Data",
                                    value: nil,
                                    isDestructive: true
                                )
                            }
                        }

                        // About section
                        SettingsSection(title: "About") {
                            SettingsRow(
                                icon: "info.circle.fill",
                                iconColor: Color.white.opacity(0.5),
                                title: "Version",
                                value: "1.0.0"
                            )

                            Button {
                                appState.resetOnboarding()
                            } label: {
                                SettingsRow(
                                    icon: "arrow.counterclockwise",
                                    iconColor: Color.white.opacity(0.5),
                                    title: "Show Onboarding",
                                    value: nil
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
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
            .confirmationDialog(
                "Clear All Data?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    appState.journeyRepository.clearAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your journey history and progress.")
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.5))
                .tracking(0.5)
                .padding(.leading, 4)

            VStack(spacing: 1) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(isDestructive ? .rfError : .white)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.3))
        }
        .padding(16)
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.rfSuccess)
        }
        .padding(16)
    }
}

// MARK: - Map Style Settings View

struct MapStyleSettingsView: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(MapStyle.allCases) { style in
                        Button {
                            appState.settings.mapStyle = style
                        } label: {
                            HStack {
                                Text(style.displayName)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)

                                Spacer()

                                if appState.settings.mapStyle == style {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.rfSuccess)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Map Style")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Duration Settings View

struct DurationSettingsView: View {
    @Environment(\.appState) private var appState

    private let durations = [15, 20, 25, 30, 45, 60, 90, 120]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(durations, id: \.self) { duration in
                        Button {
                            appState.settings.defaultDuration = duration
                        } label: {
                            HStack {
                                Text("\(duration) minutes")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)

                                Spacer()

                                if appState.settings.defaultDuration == duration {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.rfSuccess)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Default Duration")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    NewSettingsView()
        .environment(\.appState, AppState())
}
