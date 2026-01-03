//
//  InsightsView.swift
//  RailFocus
//
//  Analytics and insights dashboard
//

import SwiftUI

struct InsightsView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RFSpacing.lg) {
                    // Weekly chart
                    weeklyChartSection

                    // Stats cards
                    statsCardsSection

                    // Tag breakdown
                    tagBreakdownSection

                    // Rail map preview
                    railMapPreviewSection
                }
                .padding(.horizontal, RFSpacing.md)
                .padding(.top, RFSpacing.md)
            }
            .rfBackground()
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Weekly Chart Section

    private var weeklyChartSection: some View {
        Card(shadow: .subtle) {
            VStack(alignment: .leading, spacing: RFSpacing.md) {
                Text("This Week")
                    .font(RFTypography.headline.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                // Simple bar chart
                HStack(alignment: .bottom, spacing: RFSpacing.sm) {
                    ForEach(weekDays, id: \.self) { day in
                        WeekDayBar(
                            day: day,
                            value: sampleData[day] ?? 0,
                            maxValue: 120,
                            isToday: day == currentDayAbbreviation
                        )
                    }
                }
                .frame(height: 120)

                // Legend
                HStack(spacing: RFSpacing.lg) {
                    LegendItem(label: "Total", value: "2h 15m")
                    LegendItem(label: "Average", value: "27m/day")
                }
            }
        }
    }

    // MARK: - Stats Cards Section

    private var statsCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: RFSpacing.sm),
            GridItem(.flexible(), spacing: RFSpacing.sm)
        ], spacing: RFSpacing.sm) {
            StatCard(
                title: "Current Streak",
                value: "0",
                unit: "days",
                icon: "flame.fill",
                iconColor: .orange
            )

            StatCard(
                title: "Total Journeys",
                value: "0",
                unit: "completed",
                icon: "tram.fill",
                iconColor: theme.accentStyle.color
            )

            StatCard(
                title: "Focus Time",
                value: "0",
                unit: "hours",
                icon: "clock.fill",
                iconColor: .rfEmerald
            )

            StatCard(
                title: "Longest Ride",
                value: "0",
                unit: "minutes",
                icon: "trophy.fill",
                iconColor: .rfCrimson
            )
        }
    }

    // MARK: - Tag Breakdown Section

    private var tagBreakdownSection: some View {
        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            CompactSectionHeader("Focus Breakdown", icon: "chart.pie.fill")

            Card {
                VStack(spacing: RFSpacing.md) {
                    if hasData {
                        ForEach(FocusTag.allCases) { tag in
                            TagBreakdownRow(
                                tag: tag,
                                minutes: 0,
                                percentage: 0
                            )
                        }
                    } else {
                        Text("Complete some journeys to see your focus breakdown")
                            .font(RFTypography.subheadline.font)
                            .foregroundStyle(Color.rfAdaptiveTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RFSpacing.md)
                    }
                }
            }
        }
    }

    // MARK: - Rail Map Preview Section

    private var railMapPreviewSection: some View {
        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            SectionHeader("Your Rail Map", actionTitle: "View All") {
                // Navigate to full rail map
            }

            Card {
                VStack(spacing: RFSpacing.md) {
                    // Placeholder map
                    RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                        .fill(Color.rfAdaptiveBackground)
                        .frame(height: 150)
                        .overlay(
                            VStack(spacing: RFSpacing.sm) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.rfAdaptiveTextTertiary)

                                Text("0 routes completed")
                                    .font(RFTypography.caption1.font)
                                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
                            }
                        )

                    // Progress
                    HStack {
                        Text("0 / 5 rail lines unlocked")
                            .font(RFTypography.caption1.font)
                            .foregroundStyle(Color.rfAdaptiveTextSecondary)

                        Spacer()

                        RFProgressBar(progress: 0, height: 6)
                            .frame(width: 100)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var currentDayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: Date())
    }

    private var sampleData: [String: Int] {
        // Placeholder - will be replaced with real data
        [:]
    }

    private var hasData: Bool {
        false
    }
}

// MARK: - Week Day Bar

private struct WeekDayBar: View {
    let day: String
    let value: Int
    let maxValue: Int
    let isToday: Bool

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: RFSpacing.xxs) {
            // Bar
            RoundedRectangle(cornerRadius: 4)
                .fill(isToday ? theme.accentStyle.color : Color.rfAdaptiveBorder)
                .frame(height: max(4, CGFloat(value) / CGFloat(maxValue) * 80))

            // Day label
            Text(day)
                .font(RFTypography.caption2.font)
                .foregroundStyle(
                    isToday ? theme.accentStyle.color : Color.rfAdaptiveTextTertiary
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Legend Item

private struct LegendItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: RFSpacing.xxs) {
            Text(label)
                .font(RFTypography.caption2.font)
                .foregroundStyle(Color.rfAdaptiveTextTertiary)

            Text(value)
                .font(RFTypography.headline.font)
                .foregroundStyle(Color.rfAdaptiveTextPrimary)
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let iconColor: Color

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: RFSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)

                VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: RFSpacing.xxs) {
                        Text(value)
                            .font(RFTypography.title2.font)
                            .foregroundStyle(Color.rfAdaptiveTextPrimary)

                        Text(unit)
                            .font(RFTypography.caption1.font)
                            .foregroundStyle(Color.rfAdaptiveTextSecondary)
                    }

                    Text(title)
                        .font(RFTypography.caption1.font)
                        .foregroundStyle(Color.rfAdaptiveTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Tag Breakdown Row

private struct TagBreakdownRow: View {
    let tag: FocusTag
    let minutes: Int
    let percentage: Double

    var body: some View {
        HStack(spacing: RFSpacing.md) {
            Circle()
                .fill(tag.color)
                .frame(width: 10, height: 10)

            Text(tag.displayName)
                .font(RFTypography.body.font)
                .foregroundStyle(Color.rfAdaptiveTextPrimary)

            Spacer()

            Text("\(minutes)m")
                .font(RFTypography.subheadline.font)
                .foregroundStyle(Color.rfAdaptiveTextSecondary)

            Text("\(Int(percentage))%")
                .font(RFTypography.caption1.font)
                .foregroundStyle(Color.rfAdaptiveTextTertiary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

#Preview {
    InsightsView()
        .environment(\.theme, Theme.shared)
}
