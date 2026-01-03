//
//  Card.swift
//  RailFocus
//
//  Elevated card container component
//

import SwiftUI

struct Card<Content: View>: View {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowStyle: RFShadow
    @ViewBuilder let content: () -> Content

    init(
        padding: CGFloat = RFSpacing.md,
        cornerRadius: CGFloat = RFCornerRadius.large,
        shadow: RFShadow = .subtle,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadow
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.rfAdaptiveSurface)
            )
            .rfShadow(shadowStyle)
    }
}

// MARK: - Bordered Card Variant

struct BorderedCard<Content: View>: View {
    let padding: CGFloat
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        padding: CGFloat = RFSpacing.md,
        cornerRadius: CGFloat = RFCornerRadius.large,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.rfAdaptiveSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.rfAdaptiveBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Glass Card Variant

struct GlassCard<Content: View>: View {
    let padding: CGFloat
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        padding: CGFloat = RFSpacing.md,
        cornerRadius: CGFloat = RFCornerRadius.large,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
    }
}

// MARK: - Previews

#Preview("Cards") {
    ScrollView {
        VStack(spacing: RFSpacing.lg) {
            Card {
                VStack(alignment: .leading, spacing: RFSpacing.sm) {
                    Text("Standard Card")
                        .font(RFTypography.headline.font)
                    Text("With subtle shadow elevation")
                        .font(RFTypography.body.font)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            BorderedCard {
                VStack(alignment: .leading, spacing: RFSpacing.sm) {
                    Text("Bordered Card")
                        .font(RFTypography.headline.font)
                    Text("With border instead of shadow")
                        .font(RFTypography.body.font)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ZStack {
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 150)

                GlassCard {
                    Text("Glass Card")
                        .font(RFTypography.headline.font)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
    }
    .background(Color.rfAdaptiveBackground)
}
