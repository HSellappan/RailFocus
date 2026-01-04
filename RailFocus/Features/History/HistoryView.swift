//
//  HistoryView.swift
//  RailFocus
//
//  Journey history screen
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if appState.journeyRepository.completedJourneys.isEmpty {
                    emptyState
                } else {
                    journeyList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.selectedMenuItem = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane")
                .font(.system(size: 48))
                .foregroundStyle(Color.white.opacity(0.3))

            Text("No Journeys Yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            Text("Complete your first focus session\nto start building your travel log.")
                .font(.system(size: 15))
                .foregroundStyle(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Journey List

    private var journeyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(groupedJourneys, id: \.date) { group in
                    Section {
                        ForEach(group.journeys) { journey in
                            JourneyHistoryRow(journey: journey)
                        }
                    } header: {
                        HStack {
                            Text(group.date.relativeDay)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.6))
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Grouped Journeys

    private var groupedJourneys: [(date: Date, journeys: [Journey])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: appState.journeyRepository.completedJourneys) { journey in
            calendar.startOfDay(for: journey.completedAt ?? Date())
        }

        return grouped
            .map { (date: $0.key, journeys: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - Journey History Row

struct JourneyHistoryRow: View {
    let journey: Journey

    var body: some View {
        HStack(spacing: 16) {
            // Route icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "airplane")
                    .font(.system(size: 18))
                    .foregroundStyle(statusColor)
                    .rotationEffect(.degrees(45))
            }

            // Journey details
            VStack(alignment: .leading, spacing: 4) {
                Text(journey.routeCode)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text(journey.formattedDuration)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.5))

                    if let tag = journey.tag {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(tagColor(for: tag))
                                .frame(width: 6, height: 6)
                            Text(tag.displayName)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                }
            }

            Spacer()

            // Time and status
            VStack(alignment: .trailing, spacing: 4) {
                Text(journey.completedAt?.timeString ?? "")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.5))

                Text(journey.status == .completed ? "LANDED" : "INTERRUPTED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(statusColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }

    private var statusColor: Color {
        journey.status == .completed ? .rfSuccess : .rfWarning
    }

    private func tagColor(for tag: FocusTag) -> Color {
        switch tag {
        case .work: return .rfElectricBlue
        case .study: return .rfEmerald
        case .coding: return .rfCrimson
        case .writing: return .orange
        case .admin: return .purple
        case .personal: return .cyan
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
        .environment(\.appState, AppState())
}
