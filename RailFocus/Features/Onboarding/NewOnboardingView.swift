//
//  NewOnboardingView.swift
//  RailFocus
//
//  Modern onboarding flow with dark theme
//

import SwiftUI
import MapKit

// MARK: - Onboarding Container

struct NewOnboardingView: View {
    @Environment(\.appState) private var appState
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentPage) {
                WelcomeOnboardingPage(onContinue: { currentPage = 1 })
                    .tag(0)

                BoardingPassOnboardingPage(onContinue: { currentPage = 2 })
                    .tag(1)

                MapStyleOnboardingPage(onContinue: { currentPage = 3 })
                    .tag(2)

                FinalOnboardingPage(onComplete: {
                    appState.completeOnboarding()
                })
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Page 1: Welcome

struct WelcomeOnboardingPage: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            // Stars background
            StarsBackgroundView()

            VStack(spacing: 0) {
                Spacer()

                // Welcome text (subtle, above main content)
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Welcome aboard!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.5))
                        Text("👋")
                            .font(.system(size: 16))
                    }

                    Text("Your journey to deep focus begins here.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.4))
                }
                .padding(.bottom, 60)

                // Main question
                VStack(alignment: .leading, spacing: 8) {
                    Text("Do you often feel")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.8))

                    GradientText("distracted?", fontSize: 42)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)

                Spacer()
                Spacer()

                // Continue button
                Button(action: onContinue) {
                    Text("Yes, I do.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Page 2: Train Ticket

struct BoardingPassOnboardingPage: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Train tickets stack
                ZStack {
                    // Background ticket (tilted)
                    TrainTicketCard(
                        origin: "TYO",
                        originCity: "Tokyo",
                        destination: "OSA",
                        destinationCity: "Osaka",
                        duration: "2h 15m",
                        date: "January 3, 2026",
                        departureTime: "5:02P",
                        arrivalTime: "7:17 PM",
                        hasArrived: false,
                        showBarcode: false
                    )
                    .rotationEffect(.degrees(-8))
                    .offset(x: -20, y: -30)
                    .opacity(0.7)

                    // Front ticket
                    TrainTicketCard(
                        origin: "TYO",
                        originCity: "Tokyo",
                        destination: "OSA",
                        destinationCity: "Osaka",
                        duration: "2h 15m",
                        date: "2026/01/03",
                        departureTime: "Now",
                        carSeat: "Car 5, Seat 12",
                        distance: "515 km",
                        trainName: "Nozomi 225",
                        railLine: "Shinkansen",
                        hasArrived: false,
                        showBarcode: true
                    )
                }
                .padding(.horizontal, 40)

                Spacer()

                // Features list
                VStack(spacing: 24) {
                    FeatureRow(
                        icon: "tram.fill",
                        title: "Focus Ticket",
                        description: "Every ride is a journey of deep focus, from departure to arrival."
                    )

                    FeatureRow(
                        icon: "clock.arrow.circlepath",
                        title: "Journey History",
                        description: "Every train ride marks a milestone in your focus journey."
                    )
                }
                .padding(.horizontal, 40)

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Page 3: Map Style

struct MapStyleOnboardingPage: View {
    let onContinue: () -> Void
    @Environment(\.appState) private var appState
    @State private var selectedStyle: MapStyle = .satellite
    @State private var showLabels = false

    var body: some View {
        ZStack {
            // Globe background
            GlobeBackgroundView()

            VStack(spacing: 0) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == 2 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 40, height: 4)
                    }
                }
                .padding(.top, 20)

                // Title
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Choose Your Map Style")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Text("🗺️")
                            .font(.system(size: 24))
                    }

                    Text("Your chosen map will appear by default on the home and ride screens.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)

                Spacer()

                // Map style grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(MapStyle.allCases) { style in
                        MapStyleCard(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            selectedStyle = style
                            appState.settings.mapStyle = style
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Labels toggle
                HStack {
                    Text("Labels")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        showLabels.toggle()
                        appState.settings.showLabels = showLabels
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(showLabels ? Color.rfSuccess : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                            Text(showLabels ? "ON" : "OFF")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Page 4: Final Welcome

struct FinalOnboardingPage: View {
    let onComplete: () -> Void
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 30, longitude: -40), distance: 40000000)
    )

    var body: some View {
        ZStack {
            // Full globe map
            Map(position: $cameraPosition) {}
                .mapStyle(.imagery(elevation: .realistic))
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Stars overlay
            StarsBackgroundView()
                .opacity(0.5)

            // Dark overlay for text contrast
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Welcome to RailFocus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                // Start button
                Button(action: onComplete) {
                    Text("Start Journey")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Supporting Views

struct GradientText: View {
    let text: String
    let fontSize: CGFloat

    init(_ text: String, fontSize: CGFloat = 42) {
        self.text = text
        self.fontSize = fontSize
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.rfGradientBlue1, .rfGradientBlue2, .rfGradientBlue3],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

struct StarsBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...2))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .opacity(Double.random(in: 0.3...0.8))
            }
        }
    }
}

struct GlobeBackgroundView: View {
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 40, longitude: -30), distance: 30000000)
    )

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Map(position: $cameraPosition) {}
                .mapStyle(.imagery(elevation: .realistic))
                .allowsHitTesting(false)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black, .black, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            StarsBackgroundView()
                .opacity(0.3)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.white.opacity(0.6))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct MapStyleCard: View {
    let style: MapStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Map preview placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(mapColor)
                    .frame(height: 100)

                Text(style.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .rfSuccess : .white)
                    .padding(12)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
        }
    }

    private var mapColor: Color {
        switch style {
        case .monochrome: return Color(hex: "2C2C2E")
        case .terra: return Color(hex: "1C2833")
        case .standard: return Color(hex: "1A4D7C")
        case .satellite: return Color(hex: "1B4D3E")
        }
    }
}

// MARK: - Preview

#Preview {
    NewOnboardingView()
        .environment(\.appState, AppState())
}
