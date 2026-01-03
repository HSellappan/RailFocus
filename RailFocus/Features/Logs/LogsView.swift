//
//  LogsView.swift
//  RailFocus
//
//  Journey history and logs view
//

import SwiftUI

struct LogsView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            Group {
                if hasJourneys {
                    journeysList
                } else {
                    emptyState
                }
            }
            .rfBackground()
            .navigationTitle("Journey Logs")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: RFSpacing.lg) {
            Image(systemName: "tram.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.rfAdaptiveTextTertiary)

            VStack(spacing: RFSpacing.sm) {
                Text("No Journeys Yet")
                    .font(RFTypography.title3.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text("Complete your first focus session\nto start building your travel log.")
                    .font(RFTypography.body.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(RFSpacing.xl)
    }

    // MARK: - Journeys List

    private var journeysList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Placeholder for future journey data
                Section {
                    ForEach(0..<3, id: \.self) { _ in
                        JourneyLogRow(
                            origin: "Tokyo",
                            destination: "Osaka",
                            duration: 45,
                            tag: .work,
                            completedAt: Date()
                        )
                    }
                } header: {
                    SectionDateHeader(date: Date())
                }
            }
            .padding(.horizontal, RFSpacing.md)
        }
    }

    // MARK: - Computed

    private var hasJourneys: Bool {
        // Will be connected to data layer later
        false
    }
}

// MARK: - Section Date Header

private struct SectionDateHeader: View {
    let date: Date

    var body: some View {
        HStack {
            Text(date.relativeDay)
                .font(RFTypography.headline.font)
                .foregroundStyle(Color.rfAdaptiveTextPrimary)

            Spacer()

            Text(date.shortDateString)
                .font(RFTypography.caption1.font)
                .foregroundStyle(Color.rfAdaptiveTextTertiary)
        }
        .padding(.vertical, RFSpacing.sm)
        .padding(.horizontal, RFSpacing.md)
        .background(Color.rfAdaptiveBackground)
    }
}

// MARK: - Journey Log Row

private struct JourneyLogRow: View {
    let origin: String
    let destination: String
    let duration: Int
    let tag: FocusTag?
    let completedAt: Date

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: RFSpacing.md) {
            // Route icon
            ZStack {
                Circle()
                    .fill(theme.accentStyle.color.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "tram.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(theme.accentStyle.color)
            }

            // Journey details
            VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                Text("\(origin) → \(destination)")
                    .font(RFTypography.body.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                HStack(spacing: RFSpacing.sm) {
                    Text("\(duration) min")
                        .font(RFTypography.caption1.font)
                        .foregroundStyle(Color.rfAdaptiveTextSecondary)

                    if let tag = tag {
                        TagPill(tag.displayName, color: tag.color)
                    }
                }
            }

            Spacer()

            // Time
            Text(completedAt.timeString)
                .font(RFTypography.caption1.font)
                .foregroundStyle(Color.rfAdaptiveTextTertiary)
        }
        .padding(RFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                .fill(Color.rfAdaptiveSurface)
        )
        .padding(.vertical, RFSpacing.xxs)
    }
}

#Preview {
    LogsView()
        .environment(\.theme, Theme.shared)
}
