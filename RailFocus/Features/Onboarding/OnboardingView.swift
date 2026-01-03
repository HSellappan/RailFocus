//
//  OnboardingView.swift
//  RailFocus
//
//  Onboarding flow for new users
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.appState) private var appState
    @Environment(\.theme) private var theme

    @State private var currentPage = 0

    private let totalPages = 4

    var body: some View {
        ZStack {
            // Background
            Color.rfAdaptiveBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(RFTypography.subheadline.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    ConceptPage()
                        .tag(1)

                    PermissionsPage()
                        .tag(2)

                    GetStartedPage()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(RFAnimation.standard, value: currentPage)

                // Bottom controls
                VStack(spacing: RFSpacing.lg) {
                    // Page indicator
                    HStack(spacing: RFSpacing.xs) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(
                                    index == currentPage
                                        ? theme.accentStyle.color
                                        : Color.rfAdaptiveTextTertiary
                                )
                                .frame(width: 8, height: 8)
                                .animation(RFAnimation.quick, value: currentPage)
                        }
                    }

                    // Action button
                    PrimaryButton(buttonTitle) {
                        if currentPage < totalPages - 1 {
                            withAnimation(RFAnimation.standard) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }
                    .padding(.horizontal, RFSpacing.lg)
                }
                .padding(.bottom, RFSpacing.xl)
            }
        }
    }

    private var buttonTitle: String {
        currentPage == totalPages - 1 ? "Get Started" : "Continue"
    }

    private func completeOnboarding() {
        appState.completeOnboarding()
    }
}

// MARK: - Welcome Page

private struct WelcomePage: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: RFSpacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(theme.accentStyle.color.opacity(0.12))
                    .frame(width: 120, height: 120)

                Image(systemName: "tram.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.accentStyle.color)
            }

            // Text
            VStack(spacing: RFSpacing.md) {
                Text("Welcome to RailFocus")
                    .font(RFTypography.title1.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text("Transform your focus sessions into\nimmersive high-speed train journeys.")
                    .font(RFTypography.body.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, RFSpacing.xl)
    }
}

// MARK: - Concept Page

private struct ConceptPage: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: RFSpacing.xl) {
            Spacer()

            // Steps
            VStack(spacing: RFSpacing.lg) {
                OnboardingStep(
                    number: 1,
                    title: "Book a Journey",
                    description: "Choose your route and focus duration"
                )

                OnboardingStep(
                    number: 2,
                    title: "Ride",
                    description: "Watch your train progress as you focus"
                )

                OnboardingStep(
                    number: 3,
                    title: "Arrive",
                    description: "Complete your session and track progress"
                )
            }

            Spacer()

            // Tagline
            Text("Focus becomes forward motion.")
                .font(RFTypography.headline.font)
                .foregroundStyle(theme.accentStyle.color)

            Spacer()
        }
        .padding(.horizontal, RFSpacing.xl)
    }
}

// MARK: - Onboarding Step

private struct OnboardingStep: View {
    let number: Int
    let title: String
    let description: String

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: RFSpacing.md) {
            // Number badge
            ZStack {
                Circle()
                    .fill(theme.accentStyle.color)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .font(RFTypography.headline.font)
                    .foregroundStyle(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                Text(title)
                    .font(RFTypography.headline.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text(description)
                    .font(RFTypography.subheadline.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
            }

            Spacer()
        }
        .padding(RFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                .fill(Color.rfAdaptiveSurface)
        )
    }
}

// MARK: - Permissions Page

private struct PermissionsPage: View {
    @State private var notificationsGranted = false
    @State private var focusModeGranted = false

    var body: some View {
        VStack(spacing: RFSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: RFSpacing.md) {
                Text("Enable Permissions")
                    .font(RFTypography.title2.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text("These help RailFocus work best for you.")
                    .font(RFTypography.body.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
            }

            // Permission cards
            VStack(spacing: RFSpacing.md) {
                PermissionCard(
                    icon: "bell.badge.fill",
                    title: "Notifications",
                    description: "Get notified when your journey is complete",
                    isGranted: notificationsGranted
                ) {
                    // Request notification permission
                    notificationsGranted = true
                }

                PermissionCard(
                    icon: "hand.raised.fill",
                    title: "Focus Mode",
                    description: "Block distracting apps during focus sessions",
                    isGranted: focusModeGranted
                ) {
                    // Request Screen Time permission
                    focusModeGranted = true
                }
            }

            Spacer()

            Text("You can change these later in Settings")
                .font(RFTypography.caption1.font)
                .foregroundStyle(Color.rfAdaptiveTextTertiary)

            Spacer()
        }
        .padding(.horizontal, RFSpacing.xl)
    }
}

// MARK: - Permission Card

private struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: RFSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        isGranted
                            ? Color.rfSuccess.opacity(0.15)
                            : theme.accentStyle.color.opacity(0.12)
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: isGranted ? "checkmark" : icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isGranted ? .rfSuccess : theme.accentStyle.color)
            }

            // Text
            VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                Text(title)
                    .font(RFTypography.headline.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text(description)
                    .font(RFTypography.caption1.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
            }

            Spacer()

            // Button
            if !isGranted {
                Button("Enable") {
                    action()
                }
                .font(RFTypography.subheadline.font)
                .fontWeight(.semibold)
                .foregroundStyle(theme.accentStyle.color)
            }
        }
        .padding(RFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: RFCornerRadius.medium)
                .fill(Color.rfAdaptiveSurface)
        )
    }
}

// MARK: - Get Started Page

private struct GetStartedPage: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: RFSpacing.xl) {
            Spacer()

            // Celebration icon
            ZStack {
                Circle()
                    .fill(theme.accentStyle.color.opacity(0.12))
                    .frame(width: 120, height: 120)

                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.accentStyle.color)
            }

            // Text
            VStack(spacing: RFSpacing.md) {
                Text("You're All Set!")
                    .font(RFTypography.title1.font)
                    .foregroundStyle(Color.rfAdaptiveTextPrimary)

                Text("Start your first journey and experience\nfocus like never before.")
                    .font(RFTypography.body.font)
                    .foregroundStyle(Color.rfAdaptiveTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // First journey suggestion
            Card {
                HStack(spacing: RFSpacing.md) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(theme.accentStyle.color)

                    VStack(alignment: .leading, spacing: RFSpacing.xxs) {
                        Text("First Journey")
                            .font(RFTypography.headline.font)
                            .foregroundStyle(Color.rfAdaptiveTextPrimary)

                        Text("Tokyo → Nagoya • 25 min")
                            .font(RFTypography.caption1.font)
                            .foregroundStyle(Color.rfAdaptiveTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.rfAdaptiveTextTertiary)
                }
            }
            .padding(.horizontal, RFSpacing.md)

            Spacer()
        }
        .padding(.horizontal, RFSpacing.xl)
    }
}

#Preview {
    OnboardingView()
        .environment(\.appState, AppState())
        .environment(\.theme, Theme.shared)
}
