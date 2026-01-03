//
//  ProgressBar.swift
//  RailFocus
//
//  Linear progress indicator components
//

import SwiftUI

struct RFProgressBar: View {
    let progress: Double
    let height: CGFloat
    let showPercentage: Bool

    @Environment(\.theme) private var theme

    init(
        progress: Double,
        height: CGFloat = 8,
        showPercentage: Bool = false
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.showPercentage = showPercentage
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: RFSpacing.xxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.rfAdaptiveBorder)
                        .frame(height: height)

                    // Fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(theme.accentStyle.color)
                        .frame(width: geometry.size.width * progress, height: height)
                        .animation(RFAnimation.standard, value: progress)
                }
            }
            .frame(height: height)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(RFTypography.caption2.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
            }
        }
    }
}

// MARK: - Journey Progress Bar

struct JourneyProgressBar: View {
    let progress: Double
    let originName: String
    let destinationName: String

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: RFSpacing.sm) {
            // Station labels
            HStack {
                Text(originName)
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)

                Spacer()

                Text(destinationName)
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
            }

            // Track with train
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track line
                    Rectangle()
                        .fill(Color.rfAdaptiveBorder)
                        .frame(height: 2)

                    // Completed track
                    Rectangle()
                        .fill(theme.accentStyle.color)
                        .frame(width: geometry.size.width * progress, height: 2)
                        .animation(RFAnimation.standard, value: progress)

                    // Origin station
                    Circle()
                        .fill(theme.accentStyle.color)
                        .frame(width: 10, height: 10)

                    // Destination station
                    Circle()
                        .fill(progress >= 1 ? theme.accentStyle.color : Color.rfAdaptiveBorder)
                        .frame(width: 10, height: 10)
                        .position(x: geometry.size.width, y: geometry.size.height / 2)

                    // Train marker
                    Image(systemName: "tram.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(theme.accentStyle.color)
                        .offset(x: (geometry.size.width - 16) * progress, y: -14)
                        .animation(RFAnimation.smoothSpring, value: progress)
                }
            }
            .frame(height: 20)
        }
    }
}

// MARK: - Circular Progress

struct CircularProgress: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    @Environment(\.theme) private var theme

    init(
        progress: Double,
        lineWidth: CGFloat = 4,
        size: CGFloat = 44
    ) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.rfAdaptiveBorder, lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    theme.accentStyle.color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(RFAnimation.standard, value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Previews

#Preview("Progress Bars") {
    VStack(spacing: RFSpacing.xl) {
        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            Text("Linear Progress")
                .font(RFTypography.headline.font)

            RFProgressBar(progress: 0.65)
            RFProgressBar(progress: 0.35, showPercentage: true)
        }

        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            Text("Journey Progress")
                .font(RFTypography.headline.font)

            JourneyProgressBar(
                progress: 0.45,
                originName: "Tokyo",
                destinationName: "Osaka"
            )
        }

        VStack(alignment: .leading, spacing: RFSpacing.sm) {
            Text("Circular Progress")
                .font(RFTypography.headline.font)

            HStack(spacing: RFSpacing.lg) {
                CircularProgress(progress: 0.25)
                CircularProgress(progress: 0.5, size: 60)
                CircularProgress(progress: 0.75, lineWidth: 6, size: 80)
            }
        }
    }
    .padding()
    .background(Color.rfAdaptiveBackground)
}
