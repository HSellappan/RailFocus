//
//  ArrivalView.swift
//  RailFocus
//
//  Journey completion/arrival screen
//

import SwiftUI

struct ArrivalView: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var showConfetti = true
    @State private var notes: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Stars background
            StarsBackgroundView()
                .opacity(0.5)

            VStack(spacing: 32) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.rfSuccess.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.rfSuccess)
                }

                // Arrival text
                VStack(spacing: 8) {
                    Text("LANDED")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.rfSuccess)
                        .tracking(2)

                    if let journey = lastJourney {
                        Text("Welcome to \(journey.destinationStation.city)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                // Stats card
                if let journey = lastJourney {
                    statsCard(for: journey)
                }

                // Notes section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Notes (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.6))

                    TextField("What did you accomplish?", text: $notes, axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .padding(16)
                        .frame(minHeight: 80, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .lineLimit(3...5)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Done button
                Button {
                    dismiss()
                    appState.showArrivalScreen = false
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Stats Card

    private func statsCard(for journey: Journey) -> some View {
        HStack(spacing: 24) {
            StatColumn(
                icon: "clock.fill",
                value: journey.formattedDuration,
                label: "Duration"
            )

            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))

            StatColumn(
                icon: "location.fill",
                value: String(format: "%.0f mi", journey.distanceMiles),
                label: "Distance"
            )

            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))

            StatColumn(
                icon: "flame.fill",
                value: "\(appState.journeyRepository.userProgress.currentStreak)",
                label: "Streak"
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private var lastJourney: Journey? {
        appState.journeyRepository.completedJourneys.first
    }
}

// MARK: - Stat Column

private struct StatColumn: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.rfSuccess)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.5))
        }
    }
}

// MARK: - Preview

#Preview {
    ArrivalView()
        .environment(\.appState, AppState())
}
