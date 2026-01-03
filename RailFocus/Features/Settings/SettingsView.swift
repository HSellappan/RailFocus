//
//  SettingsView.swift
//  RailFocus
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @State private var selectedAccent: AccentStyle = Theme.shared.accentStyle
    @State private var ambientSoundsEnabled = true
    @State private var arrivalChimeEnabled = true
    @State private var remindersEnabled = false

    var body: some View {
        NavigationStack {
            List {
                // Focus Mode Section
                Section {
                    NavigationLink {
                        Text("Manage Blocked Apps")
                    } label: {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            iconColor: .rfCrimson,
                            title: "Focus Mode",
                            subtitle: "Manage blocked apps"
                        )
                    }
                } header: {
                    Text("Focus")
                }

                // Timer Section
                Section {
                    NavigationLink {
                        Text("Timer Settings")
                    } label: {
                        SettingsRow(
                            icon: "timer",
                            iconColor: theme.accentStyle.color,
                            title: "Timer Defaults",
                            subtitle: "Duration, breaks"
                        )
                    }
                } header: {
                    Text("Timer")
                }

                // Sounds Section
                Section {
                    Toggle(isOn: $ambientSoundsEnabled) {
                        SettingsRow(
                            icon: "speaker.wave.2.fill",
                            iconColor: .rfEmerald,
                            title: "Ambient Sounds",
                            subtitle: "Train sounds during focus"
                        )
                    }
                    .tint(theme.accentStyle.color)

                    Toggle(isOn: $arrivalChimeEnabled) {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .orange,
                            title: "Arrival Chime",
                            subtitle: "Sound on journey completion"
                        )
                    }
                    .tint(theme.accentStyle.color)
                } header: {
                    Text("Sounds")
                }

                // Notifications Section
                Section {
                    Toggle(isOn: $remindersEnabled) {
                        SettingsRow(
                            icon: "clock.badge",
                            iconColor: .purple,
                            title: "Daily Reminders",
                            subtitle: "Schedule focus sessions"
                        )
                    }
                    .tint(theme.accentStyle.color)
                } header: {
                    Text("Notifications")
                }

                // Appearance Section
                Section {
                    NavigationLink {
                        AccentColorPicker(selectedAccent: $selectedAccent)
                    } label: {
                        HStack {
                            SettingsRow(
                                icon: "paintbrush.fill",
                                iconColor: selectedAccent.color,
                                title: "Accent Color",
                                subtitle: selectedAccent.displayName
                            )

                            Circle()
                                .fill(selectedAccent.color)
                                .frame(width: 24, height: 24)
                        }
                    }
                } header: {
                    Text("Appearance")
                }

                // Data Section
                Section {
                    Button {
                        // Export data
                    } label: {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: theme.accentStyle.color,
                            title: "Export Data",
                            subtitle: "Download your journey history"
                        )
                    }

                    Button(role: .destructive) {
                        // Clear history
                    } label: {
                        SettingsRow(
                            icon: "trash.fill",
                            iconColor: .rfError,
                            title: "Clear History",
                            subtitle: "Delete all journey data"
                        )
                    }
                } header: {
                    Text("Data")
                }

                // About Section
                Section {
                    NavigationLink {
                        Text("About")
                    } label: {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: Color.rfAdaptiveTextSecondary,
                            title: "About RailFocus",
                            subtitle: "Version 1.0.0"
                        )
                    }

                    Link(destination: URL(string: "https://example.com/support")!) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            iconColor: Color.rfAdaptiveTextSecondary,
                            title: "Help & Support",
                            subtitle: "Get help or report issues"
                        )
                    }
                } header: {
                    Text("About")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: selectedAccent) { _, newValue in
            Theme.shared.accentStyle = newValue
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: RFSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(RFTypography.body.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text(subtitle)
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
            }
        }
    }
}

// MARK: - Accent Color Picker

private struct AccentColorPicker: View {
    @Binding var selectedAccent: AccentStyle
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(AccentStyle.allCases) { accent in
                Button {
                    selectedAccent = accent
                } label: {
                    HStack {
                        Circle()
                            .fill(accent.color)
                            .frame(width: 24, height: 24)

                        Text(accent.displayName)
                            .font(RFTypography.body.font)
                            .foregroundStyle(Color.rfAdaptiveTextPrimary)

                        Spacer()

                        if selectedAccent == accent {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(accent.color)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Accent Color")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environment(\.theme, Theme.shared)
}
