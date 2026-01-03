//
//  SectionHeader.swift
//  RailFocus
//
//  Section header component for lists and content areas
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?

    @Environment(\.theme) private var theme

    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                Text(title)
                    .font(RFTypography.headline.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(RFTypography.caption1.font)
                        .foregroundStyle(Color.rfAdaptiveTextSecondary)
                }
            }

            Spacer()

            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(RFTypography.subheadline.font)
                        .foregroundStyle(theme.accentStyle.color)
                }
            }
        }
        .padding(.horizontal, RFSpacing.md)
        .padding(.vertical, RFSpacing.sm)
    }
}

// MARK: - Compact Section Header

struct CompactSectionHeader: View {
    let title: String
    let icon: String?

    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: RFSpacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.rfAdaptiveTextTertiary)
            }

            Text(title.uppercased())
                .font(RFTypography.caption1.font)
                .fontWeight(.semibold)
                .foregroundStyle(Color.rfAdaptiveTextTertiary)
                .tracking(0.5)

            Spacer()
        }
        .padding(.horizontal, RFSpacing.md)
        .padding(.top, RFSpacing.lg)
        .padding(.bottom, RFSpacing.xs)
    }
}

// MARK: - Previews

#Preview("Section Headers") {
    VStack(alignment: .leading, spacing: 0) {
        SectionHeader("Recent Journeys")

        SectionHeader(
            "This Week",
            subtitle: "5 journeys completed"
        )

        SectionHeader(
            "Quick Start",
            actionTitle: "See All"
        ) {
            print("See all tapped")
        }

        CompactSectionHeader("Statistics", icon: "chart.bar.fill")

        CompactSectionHeader("Settings")
    }
    .background(Color.rfAdaptiveBackground)
}
