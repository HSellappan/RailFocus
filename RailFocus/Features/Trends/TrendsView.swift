//
//  TrendsView.swift
//  RailFocus
//
//  Analytics and trends dashboard
//

import SwiftUI

struct TrendsView: View {
    @Environment(\.appState) private var appState

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Weekly chart
                        weeklyChartCard

                        // Stats grid
                        statsGrid

                        // Tag breakdown
                        tagBreakdownCard

                        // Achievements preview
                        achievementsCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Trends")
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

    // MARK: - Weekly Chart Card

    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            // Bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weekData, id: \.day) { item in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.isToday ? Color.rfSuccess : Color.white.opacity(0.3))
                            .frame(width: 32, height: max(4, CGFloat(item.minutes) / 60 * 80))

                        Text(item.day)
                            .font(.system(size: 11))
                            .foregroundStyle(
                                item.isToday ? Color.rfSuccess : Color.white.opacity(0.5)
                            )
                    }
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)

            // Summary
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.5))
                    Text(formatDuration(totalMinutes))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Average")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.5))
                    Text(formatDuration(averageMinutes) + "/day")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            StatCard(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(appState.journeyRepository.userProgress.currentStreak)",
                label: "Current Streak"
            )

            StatCard(
                icon: "airplane",
                iconColor: .rfElectricBlue,
                value: "\(appState.journeyRepository.userProgress.totalJourneysCompleted)",
                label: "Total Flights"
            )

            StatCard(
                icon: "clock.fill",
                iconColor: .rfEmerald,
                value: appState.journeyRepository.userProgress.formattedFocusTime,
                label: "Focus Time"
            )

            StatCard(
                icon: "globe.americas.fill",
                iconColor: .cyan,
                value: appState.journeyRepository.userProgress.formattedDistance,
                label: "Distance"
            )
        }
    }

    // MARK: - Tag Breakdown Card

    private var tagBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus Breakdown")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            if tagData.isEmpty {
                Text("Complete journeys with tags to see breakdown")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(tagData, id: \.tag) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)

                        Text(item.tag)
                            .font(.system(size: 15))
                            .foregroundStyle(.white)

                        Spacer()

                        Text(formatDuration(item.minutes))
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white.opacity(0.6))

                        Text("\(item.percentage)%")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.4))
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Achievements Card

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(appState.journeyRepository.userProgress.achievements.count) unlocked")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            if appState.journeyRepository.userProgress.achievements.isEmpty {
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.white.opacity(0.3))
                            )
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(appState.journeyRepository.userProgress.achievements, id: \.id) { achievement in
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.rfSuccess.opacity(0.15))
                                        .frame(width: 50, height: 50)

                                    Image(systemName: achievement.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.rfSuccess)
                                }

                                Text(achievement.name)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.white.opacity(0.7))
                                    .lineLimit(1)
                            }
                            .frame(width: 70)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Data

    private var weekData: [(day: String, minutes: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let weekday = calendar.component(.weekday, from: today)

        let journeysByDay = appState.journeyRepository.journeysByDay(forDays: 7)

        return days.enumerated().map { index, day in
            let isToday = (index + 2) % 7 == weekday || (index == 6 && weekday == 1)
            let duration = journeysByDay[safe: index]?.duration ?? 0
            return (day: day, minutes: Int(duration / 60), isToday: isToday)
        }
    }

    private var totalMinutes: Int {
        weekData.reduce(0) { $0 + $1.minutes }
    }

    private var averageMinutes: Int {
        let activeDays = weekData.filter { $0.minutes > 0 }.count
        return activeDays > 0 ? totalMinutes / activeDays : 0
    }

    private var tagData: [(tag: String, minutes: Int, percentage: Int, color: Color)] {
        let journeys = appState.journeyRepository.thisWeekJourneys
        var tagMinutes: [FocusTag: Int] = [:]

        for journey in journeys {
            if let tag = journey.tag {
                let duration = Int((journey.actualDuration ?? journey.scheduledDuration) / 60)
                tagMinutes[tag, default: 0] += duration
            }
        }

        let total = tagMinutes.values.reduce(0, +)
        guard total > 0 else { return [] }

        return tagMinutes.map { tag, minutes in
            let percentage = (minutes * 100) / total
            let color: Color = {
                switch tag {
                case .work: return .rfElectricBlue
                case .study: return .rfEmerald
                case .coding: return .rfCrimson
                case .writing: return .orange
                case .admin: return .purple
                case .personal: return .cyan
                }
            }()
            return (tag: tag.displayName, minutes: minutes, percentage: percentage, color: color)
        }.sorted { $0.minutes > $1.minutes }
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - Preview

#Preview {
    TrendsView()
        .environment(\.appState, AppState())
}
