//
//  RideModeView.swift
//  RailFocus
//
//  Full-screen immersive focus session view
//

import SwiftUI

struct RideModeView: View {
    @Environment(\.appState) private var appState
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var timeRemaining: TimeInterval = .minutes(25)
    @State private var totalDuration: TimeInterval = .minutes(25)
    @State private var isPaused = false
    @State private var showEndConfirmation = false
    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            // Background gradient (placeholder for map)
            backgroundView

            // Content overlay
            VStack(spacing: 0) {
                // Top HUD
                topHUD

                Spacer()

                // Train progress indicator
                trainProgressView

                Spacer()

                // Bottom controls
                bottomControlCard
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .onAppear {
            startTimer()
        }
        .confirmationDialog(
            "End Journey Early?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Journey", role: .destructive) {
                endJourney()
            }
            Button("Continue Riding", role: .cancel) {}
        } message: {
            Text("Your progress will be saved, but this journey will be marked as interrupted.")
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [
                    Color(hex: "0A1628"),
                    Color(hex: "1A2F4A"),
                    Color(hex: "0A1628")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle grid pattern (track visualization)
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 40
                    // Horizontal lines
                    for y in stride(from: 0, to: geometry.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.03), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Top HUD

    private var topHUD: some View {
        HStack {
            // Tag badge
            if let tag = FocusTag.work {
                HStack(spacing: RFSpacing.xxs) {
                    Image(systemName: tag.icon)
                        .font(.system(size: 12))
                    Text(tag.displayName)
                        .font(RFTypography.caption1.font)
                }
                .padding(.horizontal, RFSpacing.sm)
                .padding(.vertical, RFSpacing.xxs)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                )
                .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            // Route name
            Text("Tokyo → Osaka")
                .font(RFTypography.subheadline.font)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, RFSpacing.lg)
        .padding(.top, RFSpacing.xl)
    }

    // MARK: - Train Progress

    private var trainProgressView: some View {
        VStack(spacing: RFSpacing.xl) {
            // Large time display
            VStack(spacing: RFSpacing.xs) {
                Text(timeRemaining.countdownString)
                    .font(.system(size: 72, weight: .light, design: .monospaced))
                    .foregroundStyle(.white)

                Text("remaining")
                    .font(RFTypography.subheadline.font)
                    .foregroundStyle(.white.opacity(0.5))
            }

            // Progress track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.accentStyle.color)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(RFAnimation.standard, value: progress)

                    // Train marker
                    Image(systemName: "tram.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(theme.accentStyle.color)
                        .offset(x: (geometry.size.width - 24) * progress, y: -16)
                        .animation(RFAnimation.smoothSpring, value: progress)

                    // Origin marker
                    Circle()
                        .fill(theme.accentStyle.color)
                        .frame(width: 12, height: 12)

                    // Destination marker
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 12, height: 12)
                        .position(x: geometry.size.width, y: 2)
                }
            }
            .frame(height: 40)
            .padding(.horizontal, RFSpacing.xl)

            // Station labels
            HStack {
                Text("Tokyo")
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                Text("Osaka")
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, RFSpacing.xl)
        }
    }

    // MARK: - Bottom Control Card

    private var bottomControlCard: some View {
        VStack(spacing: RFSpacing.lg) {
            // Speed indicator (thematic)
            HStack(spacing: RFSpacing.lg) {
                StatIndicator(
                    value: "285",
                    unit: "km/h",
                    label: "Speed"
                )

                StatIndicator(
                    value: formattedDistance,
                    unit: "km",
                    label: "Remaining"
                )
            }

            // Control buttons
            HStack(spacing: RFSpacing.md) {
                // Pause/Resume button
                Button {
                    withAnimation(RFAnimation.quick) {
                        isPaused.toggle()
                    }
                } label: {
                    HStack(spacing: RFSpacing.xs) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(isPaused ? "Resume" : "Pause")
                            .font(RFTypography.headline.font)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: RFSize.buttonHeight)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: RFCornerRadius.standard)
                            .fill(Color.white.opacity(0.15))
                    )
                }

                // End button
                Button {
                    showEndConfirmation = true
                } label: {
                    HStack(spacing: RFSpacing.xs) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                        Text("End")
                            .font(RFTypography.headline.font)
                    }
                    .frame(width: 100)
                    .frame(height: RFSize.buttonHeight)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: RFCornerRadius.standard)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(RFSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: RFCornerRadius.xl)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Helpers

    private var formattedDistance: String {
        let totalDistance = 515.0 // km Tokyo to Osaka
        let remaining = totalDistance * (1 - progress)
        return String(format: "%.0f", remaining)
    }

    // MARK: - Timer Logic

    private func startTimer() {
        // Timer will be implemented properly in Phase 2
        // For now, just update progress for preview
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard !isPaused else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = 1 - (timeRemaining / totalDuration)
            } else {
                timer.invalidate()
                completeJourney()
            }
        }
    }

    private func completeJourney() {
        // Will be implemented in Phase 6
        appState.endJourney()
    }

    private func endJourney() {
        appState.endJourney()
    }
}

// MARK: - Stat Indicator

private struct StatIndicator: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: RFSpacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)

                Text(unit)
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text(label)
                .font(RFTypography.caption2.font)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

#Preview {
    RideModeView()
        .environment(\.appState, AppState())
        .environment(\.theme, Theme.shared)
}
