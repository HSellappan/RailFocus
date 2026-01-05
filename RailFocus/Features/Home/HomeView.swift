//
//  HomeView.swift
//  RailFocus
//
//  Home screen for booking journeys
//

import SwiftUI

struct HomeView: View {
    @Environment(\.appState) private var appState
    @Environment(\.theme) private var theme

    @State private var selectedDuration: Int = 25
    @State private var selectedTag: FocusTag? = nil
    @State private var showStationPicker = false

    private let durationOptions = [25, 45, 60, 90]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RFSpacing.lg) {
                    // Journey booking card
                    journeyBookingCard

                    // Quick journeys section
                    quickJourneysSection

                    // Today's summary
                    todaySummarySection
                }
                .padding(.horizontal, RFSpacing.md)
                .padding(.top, RFSpacing.md)
            }
            .rfBackground()
            .navigationTitle("RailFocus")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Journey Booking Card

    private var journeyBookingCard: some View {
        Card(shadow: .medium) {
            VStack(spacing: RFSpacing.lg) {
                // Route display
                routeSelector

                // Duration picker
                VStack(alignment: .leading, spacing: RFSpacing.sm) {
                    Text("Duration")
                        .font(RFTypography.subheadline.font)
                        .foregroundStyle(Color.rfAdaptiveTextSecondary)

                    HStack(spacing: RFSpacing.sm) {
                        ForEach(durationOptions, id: \.self) { duration in
                            DurationPill(
                                minutes: duration,
                                isSelected: selectedDuration == duration
                            ) {
                                withAnimation(RFAnimation.quick) {
                                    selectedDuration = duration
                                }
                            }
                        }
                    }
                }

                // Tag selector
                VStack(alignment: .leading, spacing: RFSpacing.sm) {
                    Text("Tag (optional)")
                        .font(RFTypography.subheadline.font)
                        .foregroundStyle(Color.rfAdaptiveTextSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: RFSpacing.sm) {
                            ForEach(FocusTag.allCases) { tag in
                                Pill(
                                    tag.displayName,
                                    icon: tag.icon,
                                    isSelected: selectedTag == tag
                                ) {
                                    withAnimation(RFAnimation.quick) {
                                        selectedTag = selectedTag == tag ? nil : tag
                                    }
                                }
                            }
                        }
                    }
                }

                // Start button
                PrimaryButton("Start Journey", icon: "play.fill") {
                    startJourney()
                }
            }
        }
    }

    // MARK: - Route Selector

    private var routeSelector: some View {
        Button {
            showStationPicker = true
        } label: {
            HStack(spacing: RFSpacing.md) {
                // Origin
                VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                    Text("FROM")
                        .font(RFTypography.caption2.font)
                        .foregroundStyle(Color.rfAdaptiveTextTertiary)
                    Text("Tokyo")
                        .font(RFTypography.headline.font)
                        .foregroundStyle(Color.rfAdaptiveTextPrimary)
                }

                Spacer()

                // Route indicator
                HStack(spacing: RFSpacing.xxs) {
                    Circle()
                        .fill(theme.accentStyle.color)
                        .frame(width: 8, height: 8)

                    Rectangle()
                        .fill(theme.accentStyle.color.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: 60)

                    Image(systemName: "tram.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.accentStyle.color)

                    Rectangle()
                        .fill(theme.accentStyle.color.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: 60)

                    Circle()
                        .stroke(theme.accentStyle.color, lineWidth: 2)
                        .frame(width: 8, height: 8)
                }

                Spacer()

                // Destination
                VStack(alignment: .trailing, spacing: RFSpacing.xxs) {
                    Text("TO")
                        .font(RFTypography.caption2.font)
                        .foregroundStyle(Color.rfAdaptiveTextTertiary)
                    Text("Osaka")
                        .font(RFTypography.headline.font)
                        .foregroundStyle(Color.rfAdaptiveTextPrimary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.rfAdaptiveTextTertiary)
            }
            .padding(RFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                    .fill(Color.rfAdaptiveBackground)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quick Journeys Section

    private var quickJourneysSection: some View {
        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            SectionHeader("Quick Start", actionTitle: "See All") {
                // Navigate to all routes
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RFSpacing.sm) {
                    QuickJourneyCard(
                        name: "Morning Focus",
                        route: "Tokyo → Nagoya",
                        duration: 45
                    ) {
                        selectedDuration = 45
                        startJourney()
                    }

                    QuickJourneyCard(
                        name: "Deep Work",
                        route: "Paris → Lyon",
                        duration: 90
                    ) {
                        selectedDuration = 90
                        startJourney()
                    }
                }
            }
        }
    }

    // MARK: - Today's Summary Section

    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            CompactSectionHeader("Today", icon: "calendar")

            Card {
                HStack(spacing: RFSpacing.lg) {
                    SummaryItem(value: "0", label: "Journeys", icon: "tram.fill")
                    SummaryItem(value: "0m", label: "Focus Time", icon: "clock.fill")
                    SummaryItem(value: "0", label: "Streak", icon: "flame.fill")
                }
            }
        }
    }

    // MARK: - Actions

    private func startJourney() {
        let journey = Journey(
            origin: .tokyo,
            destination: .osaka,
            duration: TimeInterval(25 * 60)
        )
        appState.startJourney(journey)
    }
}

// MARK: - Quick Journey Card

private struct QuickJourneyCard: View {
    let name: String
    let route: String
    let duration: Int
    let action: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: RFSpacing.sm) {
                Text(name)
                    .font(RFTypography.headline.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text(route)
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)

                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("\(duration) min")
                        .font(RFTypography.caption1.font)
                }
                .foregroundStyle(theme.accentStyle.color)
            }
            .frame(width: 140, alignment: .leading)
            .padding(RFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                    .fill(Color.rfAdaptiveSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                            .stroke(Color.rfAdaptiveBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Summary Item

private struct SummaryItem: View {
    let value: String
    let label: String
    let icon: String

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: RFSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(theme.accentStyle.color)

            Text(value)
                .font(RFTypography.title3.font)
                .foregroundStyle(Color.rfAdaptiveTextPrimary)

            Text(label)
                .font(RFTypography.caption2.font)
                .foregroundStyle(Color.rfAdaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environment(\.appState, AppState())
        .environment(\.theme, Theme.shared)
}
