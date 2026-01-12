//
//  SessionHUDView.swift
//  RailFocus
//
//  Minimal HUD overlay for journey session.
//  Shows status, announcements, and controls.
//

import SwiftUI

// MARK: - Session HUD View

struct SessionHUDView: View {
    let phase: JourneyPhase
    let progress: Double
    let timeRemaining: String
    let nextStation: StationMilestone?
    let originCode: String
    let destinationCode: String

    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    @State private var showEndConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar

            Spacer()

            // Bottom controls
            bottomControls
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .top) {
            // Route info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(originCode)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.5))

                    Text(destinationCode)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.7))
                }

                Text(phase.displayText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Spacer()

            // Focus locked indicator
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                Text("RAIL MODE")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(Color.white.opacity(0.6))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Phase info and next station
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let next = nextStation {
                        Text("Next: \(next.name)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    Text(timeRemaining)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.5))
                }

                Spacer()

                // Progress percentage (subtle)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.4))
            }

            // Control buttons
            HStack(spacing: 12) {
                // Pause/Resume button
                Button {
                    if phase == .paused {
                        onResume()
                    } else {
                        onPause()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: phase == .paused ? "play.fill" : "pause.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(phase == .paused ? "Resume" : "Pause")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
                }

                // End button
                Button {
                    showEndConfirmation = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                        Text("End")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 48)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
        .confirmationDialog(
            "Leave the train?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End session", role: .destructive) {
                onEnd()
            }
            Button("Keep going", role: .cancel) {}
        } message: {
            Text("You'll stop at the next station. Your progress will be saved.")
        }
    }
}

// MARK: - Announcement Toast

struct AnnouncementToast: View {
    let message: String
    @Binding var isShowing: Bool

    @State private var opacity: Double = 0

    var body: some View {
        if isShowing {
            HStack(spacing: 10) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 1
                }

                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isShowing = false
                    }
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Interruption Overlay

struct InterruptionOverlay: View {
    let onReturn: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Dark backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.white.opacity(0.6))

                VStack(spacing: 8) {
                    Text("Please remain seated")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Returning keeps us on schedule.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.6))
                }

                Button {
                    onReturn()
                } label: {
                    Text("Continue Journey")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 200, height: 50)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1
            }
        }
    }
}

// MARK: - Arrival Screen

struct ArrivalSummaryView: View {
    let destinationName: String
    let totalDuration: TimeInterval
    let stationsPassed: Int
    let onLogNotes: () -> Void
    let onNewJourney: () -> Void
    let onDismiss: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            // Celebration background
            LinearGradient(
                colors: [
                    Color(hex: "1a1a2e"),
                    Color(hex: "16213e"),
                    Color(hex: "0f3460")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Celebration icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)

                // Arrival message
                VStack(spacing: 8) {
                    Text("You've arrived at")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.6))

                    Text(destinationName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Stats
                HStack(spacing: 32) {
                    StatBadge(
                        value: formatDuration(totalDuration),
                        label: "Focus time"
                    )

                    StatBadge(
                        value: "\(stationsPassed)",
                        label: "Stations"
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    Button {
                        onLogNotes()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                            Text("Log notes")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                        )
                    }

                    Button {
                        onNewJourney()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "train.side.front.car")
                            Text("Start another journey")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview("HUD") {
    ZStack {
        Color.black.ignoresSafeArea()

        SessionHUDView(
            phase: .cruising,
            progress: 0.45,
            timeRemaining: "12:30",
            nextStation: StationMilestone(name: "Riverside", progressPosition: 0.5),
            originCode: "PAR",
            destinationCode: "LYO",
            onPause: {},
            onResume: {},
            onEnd: {}
        )
    }
}

#Preview("Announcement") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()
            AnnouncementToast(
                message: "Smooth ride — keep going.",
                isShowing: .constant(true)
            )
            .padding(.bottom, 100)
        }
    }
}

#Preview("Arrival") {
    ArrivalSummaryView(
        destinationName: "Lyon Part-Dieu",
        totalDuration: 1800,
        stationsPassed: 4,
        onLogNotes: {},
        onNewJourney: {},
        onDismiss: {}
    )
}
