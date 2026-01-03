//
//  PrimaryButton.swift
//  RailFocus
//
//  Primary call-to-action button component
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    @Environment(\.theme) private var theme

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: RFSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: RFSize.iconMedium, weight: .semibold))
                    }
                    Text(title)
                        .font(RFTypography.headline.font)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: RFSize.buttonHeight)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: RFCornerRadius.standard)
                    .fill(isDisabled ? theme.accentStyle.color.opacity(0.5) : theme.accentStyle.color)
            )
        }
        .disabled(isDisabled || isLoading)
        .animation(RFAnimation.quick, value: isLoading)
        .animation(RFAnimation.quick, value: isDisabled)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @Environment(\.theme) private var theme

    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: RFSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: RFSize.iconMedium, weight: .medium))
                }
                Text(title)
                    .font(RFTypography.headline.font)
            }
            .frame(maxWidth: .infinity)
            .frame(height: RFSize.buttonHeightSecondary)
            .foregroundStyle(theme.accentStyle.color)
            .background(
                RoundedRectangle(cornerRadius: RFCornerRadius.standard)
                    .stroke(theme.accentStyle.color, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Text Button

struct TextButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @Environment(\.theme) private var theme

    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: RFSpacing.xxs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: RFSize.iconSmall, weight: .medium))
                }
                Text(title)
                    .font(RFTypography.body.font)
            }
            .foregroundStyle(theme.accentStyle.color)
        }
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: RFSpacing.md) {
        PrimaryButton("Start Journey", icon: "tram.fill") {}
        PrimaryButton("Loading...", isLoading: true) {}
        PrimaryButton("Disabled", isDisabled: true) {}
    }
    .padding()
}

#Preview("Secondary Button") {
    VStack(spacing: RFSpacing.md) {
        SecondaryButton("View Details", icon: "arrow.right") {}
        SecondaryButton("Cancel") {}
    }
    .padding()
}
