//
//  TrainFocusSessionView.swift
//  RailFocus
//
//  Main focus session view combining all journey elements.
//  Creates an immersive train journey experience for deep focus.
//

import SwiftUI

// MARK: - Train Focus Session View

struct TrainFocusSessionView: View {
    let journey: Journey
    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var sessionController = JourneySessionController()
    @State private var currentAnnouncement: String?
    @State private var showAnnouncement = false
    @State private var showInterruptionOverlay = false
    @State private var showArrivalSummary = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Layer 1: Immersive background
            ImmersionBackgroundView(
                progress: sessionController.displayProgress,
                isInTunnel: sessionController.isInTunnel,
                phase: sessionController.phase
            )

            // Layer 2: Route progress (centered)
            routeProgressLayer

            // Layer 3: HUD overlay
            SessionHUDView(
                phase: sessionController.phase,
                progress: sessionController.progress,
                timeRemaining: sessionController.formattedTimeRemaining,
                nextStation: sessionController.nextStation,
                originCode: journey.originStation.code,
                destinationCode: journey.destinationStation.code,
                onPause: { sessionController.pause() },
                onResume: { sessionController.resume() },
                onEnd: { sessionController.endEarly() }
            )

            // Layer 4: Announcements
            VStack {
                Spacer()
                AnnouncementToast(
                    message: currentAnnouncement ?? "",
                    isShowing: $showAnnouncement
                )
                .padding(.bottom, 140)
            }

            // Interruption overlay
            if showInterruptionOverlay {
                InterruptionOverlay {
                    showInterruptionOverlay = false
                    sessionController.resume()
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .onAppear {
            setupSession()
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: sessionController.phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
        .fullScreenCover(isPresented: $showArrivalSummary) {
            ArrivalSummaryView(
                destinationName: journey.destinationStation.name,
                totalDuration: journey.scheduledDuration,
                stationsPassed: sessionController.passedStationCount,
                onLogNotes: {
                    showArrivalSummary = false
                    onComplete()
                },
                onNewJourney: {
                    showArrivalSummary = false
                    onComplete()
                },
                onDismiss: {
                    showArrivalSummary = false
                    onComplete()
                }
            )
        }
    }

    // MARK: - Route Progress Layer

    private var routeProgressLayer: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()

                // Vertical route on the right side
                TrainRouteProgressView(
                    progress: sessionController.displayProgress,
                    stations: sessionController.stations,
                    originName: journey.originStation.code,
                    destinationName: journey.destinationStation.code,
                    isVertical: true
                )
                .frame(width: 120)
                .padding(.trailing, 20)
                .padding(.vertical, 80)
            }
        }
    }

    // MARK: - Setup

    private func setupSession() {
        // Configure the session controller
        sessionController.configure(
            duration: journey.scheduledDuration,
            originName: journey.originStation.name,
            destinationName: journey.destinationStation.name
        )

        // Set up callbacks
        sessionController.onAnnouncement = { message in
            showAnnouncement(message)
        }

        sessionController.onStationPassed = { station in
            // Station pass is already handled by announcement
        }

        sessionController.onTunnelEnter = {
            SoundEngine.shared.playTunnelWhoosh()
        }

        sessionController.onComplete = {
            showArrivalSummary = true
        }

        // Start the journey immediately (boarding phase)
        sessionController.completeTicketRipping()
    }

    private func showAnnouncement(_ message: String) {
        currentAnnouncement = message
        showAnnouncement = true
    }

    // MARK: - Phase Handling

    private func handlePhaseChange(_ phase: JourneyPhase) {
        switch phase {
        case .interrupted:
            showInterruptionOverlay = true

        case .cancelled:
            onCancel()

        case .arrived:
            // Arrival summary will show via fullScreenCover
            break

        default:
            showInterruptionOverlay = false
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // Session controller handles this internally
            break

        case .active:
            if sessionController.phase == .interrupted {
                showInterruptionOverlay = true
            }

        default:
            break
        }
    }
}

// MARK: - Journey Session Wrapper

/// Wrapper view that handles the complete journey flow:
/// Ticket ripping → Focus session → Arrival
struct JourneySessionWrapper: View {
    let journey: Journey
    let seat: String?
    let focusTag: FocusTag?
    let onComplete: () -> Void

    @State private var sessionPhase: SessionWrapperPhase = .ticketRipping
    @State private var ticketRipProgress: CGFloat = 0
    @State private var showSession = false

    enum SessionWrapperPhase {
        case ticketRipping
        case transitioning
        case inSession
        case completed
    }

    var body: some View {
        ZStack {
            switch sessionPhase {
            case .ticketRipping:
                EnhancedTicketRipView(
                    journey: journey,
                    seat: seat,
                    focusTag: focusTag,
                    onRipComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            sessionPhase = .transitioning
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            sessionPhase = .inSession
                        }
                    }
                )
                .transition(.opacity)

            case .transitioning:
                // Platform reveal transition
                PlatformRevealView()
                    .transition(.opacity)

            case .inSession:
                TrainFocusSessionView(
                    journey: journey,
                    onComplete: {
                        sessionPhase = .completed
                        onComplete()
                    },
                    onCancel: {
                        sessionPhase = .completed
                        onComplete()
                    }
                )
                .transition(.opacity)

            case .completed:
                Color.black
            }
        }
        .animation(.easeInOut(duration: 0.4), value: sessionPhase)
    }
}

// MARK: - Platform Reveal View

struct PlatformRevealView: View {
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Dark background
            Color.black

            // Platform elements sliding up
            VStack(spacing: 0) {
                Spacer()

                // Platform line
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)

                // Station platform
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2d2d44"), Color(hex: "1a1a2e")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 100)
            }
            .offset(y: offsetY)
            .opacity(opacity)

            // "Boarding" text
            VStack {
                Spacer()

                Text("All aboard")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .opacity(opacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                offsetY = 0
                opacity = 1
            }
        }
    }
}

// MARK: - Enhanced Ticket Rip View

struct EnhancedTicketRipView: View {
    let journey: Journey
    let seat: String?
    let focusTag: FocusTag?
    let onRipComplete: () -> Void

    @State private var ripProgress: CGFloat = 0
    @State private var isDragging = false
    @State private var topHalfOffset: CGFloat = 0
    @State private var bottomHalfOffset: CGFloat = 0
    @State private var topHalfOpacity: Double = 1
    @State private var bottomHalfOpacity: Double = 1
    @State private var isRipComplete = false
    @State private var shakeOffset: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let ripThreshold: CGFloat = 0.7

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            StarsBackgroundView()
                .opacity(0.15)

            VStack {
                Spacer()

                // Ticket
                ZStack {
                    if !isRipComplete {
                        // Full ticket
                        ticketView
                            .offset(x: shakeOffset)
                    } else {
                        // Split ticket halves
                        VStack(spacing: 0) {
                            topHalf
                                .offset(y: topHalfOffset)
                                .opacity(topHalfOpacity)

                            bottomHalf
                                .offset(y: bottomHalfOffset)
                                .opacity(bottomHalfOpacity)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Instructions
                if !isRipComplete {
                    VStack(spacing: 8) {
                        Text("Tear to board")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.7))

                        // Progress indicator
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)

                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * ripProgress, height: 4)
                            }
                        }
                        .frame(width: 100, height: 4)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .gesture(ripGesture)
    }

    // MARK: - Ticket View

    private var ticketView: some View {
        VStack(spacing: 0) {
            // Top section
            topHalf

            // Rip line
            ripLineView
                .gesture(ripGesture)

            // Bottom section
            bottomHalf
        }
    }

    private var topHalf: some View {
        VStack(spacing: 0) {
            ZStack {
                WorldMapDotsView()
                    .opacity(0.12)

                VStack(spacing: 20) {
                    // Route
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(journey.originStation.code)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                            Text(journey.originStation.city)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }

                        Spacer()

                        VStack(spacing: 4) {
                            Image(systemName: "train.side.front.car")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.4))
                            Text(journey.formattedDuration)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(journey.destinationStation.code)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                            Text(journey.destinationStation.city)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                    }

                    // Details
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SEAT")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.white.opacity(0.4))
                            Text(seat ?? "12A")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("DEPARTS")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.white.opacity(0.4))
                            Text("Now")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16
            )
            .fill(Color(white: 0.12))
        )
    }

    private var bottomHalf: some View {
        VStack(spacing: 0) {
            // Barcode
            HStack(spacing: 1.5) {
                ForEach(0..<35, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: barcodeWidth(for: i), height: 50)
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0
            )
            .fill(Color(white: 0.12))
        )
    }

    private var ripLineView: some View {
        ZStack {
            // Dashed perforation
            HStack(spacing: 3) {
                ForEach(0..<50, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }

            // Drag handle
            Circle()
                .fill(Color.white.opacity(isDragging ? 0.8 : 0.5))
                .frame(width: 32, height: 32)
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .shadow(color: .white.opacity(0.3), radius: isDragging ? 12 : 6)
        }
        .frame(height: 32)
        .background(Color(white: 0.12))
    }

    // MARK: - Rip Gesture

    private var ripGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                let horizontal = abs(value.translation.width)
                ripProgress = min(1.0, horizontal / 150)

                // Shake when near threshold
                if ripProgress > 0.5 && ripProgress < ripThreshold {
                    withAnimation(.easeInOut(duration: 0.05)) {
                        shakeOffset = CGFloat.random(in: -2...2)
                    }
                }
            }
            .onEnded { value in
                isDragging = false
                shakeOffset = 0

                if ripProgress >= ripThreshold {
                    completeRip()
                } else {
                    // Spring back
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        ripProgress = 0
                    }

                    // Shake if close
                    if ripProgress > 0.4 {
                        withAnimation(.easeInOut(duration: 0.1).repeatCount(3)) {
                            shakeOffset = 5
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            shakeOffset = 0
                        }
                    }
                }
            }
    }

    private func completeRip() {
        HapticsEngine.shared.playTicketRip()
        SoundEngine.shared.playTicketRip()

        withAnimation(.easeOut(duration: 0.4)) {
            isRipComplete = true
            topHalfOffset = -100
            topHalfOpacity = 0
            bottomHalfOffset = 100
            bottomHalfOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onRipComplete()
        }
    }

    private func barcodeWidth(for index: Int) -> CGFloat {
        let widths: [CGFloat] = [2, 4, 2, 3, 5, 2, 4, 2, 3, 2, 5, 3, 2, 4, 2]
        return widths[index % widths.count]
    }
}

// MARK: - Preview

#Preview("Full Session") {
    TrainFocusSessionView(
        journey: Journey(
            origin: .parisGareDeLyon,
            destination: .lyonPartDieu,
            duration: 1500
        ),
        onComplete: {},
        onCancel: {}
    )
}

#Preview("Ticket Rip") {
    EnhancedTicketRipView(
        journey: Journey(
            origin: .parisGareDeLyon,
            destination: .lyonPartDieu,
            duration: 1500
        ),
        seat: "04A",
        focusTag: .work,
        onRipComplete: {}
    )
}

#Preview("Journey Wrapper") {
    JourneySessionWrapper(
        journey: Journey(
            origin: .parisGareDeLyon,
            destination: .lyonPartDieu,
            duration: 1500
        ),
        seat: "04A",
        focusTag: .work,
        onComplete: {}
    )
}
