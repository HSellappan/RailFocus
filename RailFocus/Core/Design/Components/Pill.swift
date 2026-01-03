//
//  Pill.swift
//  RailFocus
//
//  Tag and chip components
//

import SwiftUI

struct Pill: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: (() -> Void)?

    @Environment(\.theme) private var theme

    init(
        _ title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        if let action = action {
            Button(action: action) {
                pillContent
            }
            .buttonStyle(.plain)
        } else {
            pillContent
        }
    }

    @ViewBuilder
    private var pillContent: some View {
        HStack(spacing: RFSpacing.xxs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
            }
            Text(title)
                .font(RFTypography.subheadline.font)
        }
        .padding(.horizontal, RFSpacing.sm)
        .frame(height: RFSize.pillHeight)
        .foregroundStyle(isSelected ? .white : Color.rfAdaptiveTextPrimary)
        .background(
            Capsule()
                .fill(isSelected ? theme.accentStyle.color : Color.rfAdaptiveSurface)
        )
        .overlay(
            Capsule()
                .stroke(
                    isSelected ? Color.clear : Color.rfAdaptiveBorder,
                    lineWidth: 1
                )
        )
        .animation(RFAnimation.quick, value: isSelected)
    }
}

// MARK: - Duration Pill

struct DurationPill: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            Text(formattedDuration)
                .font(RFTypography.subheadline.font)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, RFSpacing.md)
                .frame(height: RFSize.pillHeight)
                .foregroundStyle(isSelected ? .white : Color.rfAdaptiveTextPrimary)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.accentStyle.color : Color.rfAdaptiveSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color.rfAdaptiveBorder,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(RFAnimation.quick, value: isSelected)
    }

    private var formattedDuration: String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

// MARK: - Tag Pill

struct TagPill: View {
    let tag: String
    let color: Color
    let isRemovable: Bool
    let onRemove: (() -> Void)?

    init(
        _ tag: String,
        color: Color = .rfElectricBlue,
        isRemovable: Bool = false,
        onRemove: (() -> Void)? = nil
    ) {
        self.tag = tag
        self.color = color
        self.isRemovable = isRemovable
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: RFSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(tag)
                .font(RFTypography.caption1.font)
                .fontWeight(.medium)

            if isRemovable {
                Button {
                    onRemove?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.rfAdaptiveTextTertiary)
                }
            }
        }
        .padding(.horizontal, RFSpacing.sm)
        .padding(.vertical, RFSpacing.xxs)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
    }
}

// MARK: - Previews

#Preview("Pills") {
    VStack(spacing: RFSpacing.lg) {
        // Standard pills
        HStack(spacing: RFSpacing.sm) {
            Pill("Tag", icon: "tag.fill")
            Pill("Selected", isSelected: true)
            Pill("Tappable") { print("Tapped") }
        }

        // Duration pills
        HStack(spacing: RFSpacing.sm) {
            DurationPill(minutes: 25, isSelected: false) {}
            DurationPill(minutes: 45, isSelected: true) {}
            DurationPill(minutes: 60, isSelected: false) {}
            DurationPill(minutes: 90, isSelected: false) {}
        }

        // Tag pills
        HStack(spacing: RFSpacing.sm) {
            TagPill("Work", color: .rfElectricBlue)
            TagPill("Study", color: .rfEmerald)
            TagPill("Coding", color: .rfCrimson, isRemovable: true) {
                print("Remove")
            }
        }
    }
    .padding()
    .background(Color.rfAdaptiveBackground)
}
