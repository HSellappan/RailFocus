//
//  UserProgress.swift
//  RailFocus
//
//  User progress and statistics model
//

import Foundation

// MARK: - User Progress

struct UserProgress: Codable {
    var totalJourneysCompleted: Int
    var totalJourneysInterrupted: Int
    var totalFocusTime: TimeInterval
    var totalDistanceTraveled: Double
    var currentStreak: Int
    var longestStreak: Int
    var lastJourneyDate: Date?
    var achievements: [Achievement]
    var visitedStations: Set<String>

    init() {
        self.totalJourneysCompleted = 0
        self.totalJourneysInterrupted = 0
        self.totalFocusTime = 0
        self.totalDistanceTraveled = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastJourneyDate = nil
        self.achievements = []
        self.visitedStations = Set<String>()
    }

    // MARK: - Computed Properties

    var totalJourneys: Int {
        totalJourneysCompleted + totalJourneysInterrupted
    }

    var completionRate: Double {
        guard totalJourneys > 0 else { return 0 }
        return Double(totalJourneysCompleted) / Double(totalJourneys)
    }

    var formattedFocusTime: String {
        let hours = Int(totalFocusTime) / 3600
        let minutes = (Int(totalFocusTime) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var formattedDistance: String {
        if totalDistanceTraveled >= 1000 {
            return String(format: "%.1fk mi", totalDistanceTraveled / 1000)
        }
        return String(format: "%.0f mi", totalDistanceTraveled)
    }

    // MARK: - Actions

    mutating func recordJourney(_ journey: Journey) {
        if journey.status == .completed {
            totalJourneysCompleted += 1
            if let duration = journey.actualDuration {
                totalFocusTime += duration
            } else {
                totalFocusTime += journey.scheduledDuration
            }
            updateStreak()
        } else if journey.status == .interrupted {
            totalJourneysInterrupted += 1
            if let duration = journey.actualDuration {
                totalFocusTime += duration
            }
        }

        totalDistanceTraveled += journey.distanceMiles
        visitedStations.insert(journey.originStation.code)
        visitedStations.insert(journey.destinationStation.code)
        lastJourneyDate = Date()

        checkAchievements()
    }

    private mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = lastJourneyDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff <= 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
    }

    private mutating func checkAchievements() {
        // First Journey
        if totalJourneysCompleted == 1 && !achievements.contains(where: { $0.id == "first_journey" }) {
            achievements.append(Achievement.firstJourney)
        }

        // 10 Journeys
        if totalJourneysCompleted >= 10 && !achievements.contains(where: { $0.id == "ten_journeys" }) {
            achievements.append(Achievement.tenJourneys)
        }

        // Week Warrior (7-day streak)
        if currentStreak >= 7 && !achievements.contains(where: { $0.id == "week_warrior" }) {
            achievements.append(Achievement.weekWarrior)
        }

        // Globe Trotter (visit 10 stations)
        if visitedStations.count >= 10 && !achievements.contains(where: { $0.id == "globe_trotter" }) {
            achievements.append(Achievement.globeTrotter)
        }
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    var unlockedAt: Date?

    static let firstJourney = Achievement(
        id: "first_journey",
        name: "First Ride",
        description: "Complete your first focus journey",
        icon: "tram.fill",
        unlockedAt: Date()
    )

    static let tenJourneys = Achievement(
        id: "ten_journeys",
        name: "Rail Regular",
        description: "Complete 10 focus journeys",
        icon: "star.fill",
        unlockedAt: Date()
    )

    static let weekWarrior = Achievement(
        id: "week_warrior",
        name: "Week Warrior",
        description: "Maintain a 7-day focus streak",
        icon: "flame.fill",
        unlockedAt: Date()
    )

    static let globeTrotter = Achievement(
        id: "globe_trotter",
        name: "Globe Trotter",
        description: "Visit 10 different destinations",
        icon: "globe.americas.fill",
        unlockedAt: Date()
    )

    static let marathon = Achievement(
        id: "marathon",
        name: "Marathon",
        description: "Complete a 90-minute focus session",
        icon: "trophy.fill",
        unlockedAt: Date()
    )
}
