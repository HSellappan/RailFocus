//
//  JourneyRepository.swift
//  RailFocus
//
//  Data persistence for journeys
//

import Foundation

// MARK: - Journey Repository

@Observable
final class JourneyRepository {
    // MARK: - Properties

    private(set) var journeys: [Journey] = []
    private(set) var userProgress: UserProgress = UserProgress()

    private let journeysKey = "savedJourneys"
    private let progressKey = "userProgress"

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - CRUD Operations

    func add(_ journey: Journey) {
        journeys.insert(journey, at: 0)
        save()
    }

    func update(_ journey: Journey) {
        if let index = journeys.firstIndex(where: { $0.id == journey.id }) {
            journeys[index] = journey

            if journey.status == .completed || journey.status == .interrupted {
                userProgress.recordJourney(journey)
            }

            save()
        }
    }

    func delete(_ journey: Journey) {
        journeys.removeAll { $0.id == journey.id }
        save()
    }

    func find(id: UUID) -> Journey? {
        journeys.first { $0.id == id }
    }

    // MARK: - Queries

    var completedJourneys: [Journey] {
        journeys.filter { $0.status == .completed }
    }

    var inProgressJourney: Journey? {
        journeys.first { $0.status == .inProgress }
    }

    var recentJourneys: [Journey] {
        Array(completedJourneys.prefix(10))
    }

    var todayJourneys: [Journey] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completedJourneys.filter { journey in
            guard let completedAt = journey.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: today)
        }
    }

    var thisWeekJourneys: [Journey] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return []
        }
        return completedJourneys.filter { journey in
            guard let completedAt = journey.completedAt else { return false }
            return completedAt >= weekStart
        }
    }

    // MARK: - Statistics

    var todayFocusTime: TimeInterval {
        todayJourneys.reduce(0) { $0 + ($1.actualDuration ?? $1.scheduledDuration) }
    }

    var thisWeekFocusTime: TimeInterval {
        thisWeekJourneys.reduce(0) { $0 + ($1.actualDuration ?? $1.scheduledDuration) }
    }

    func journeysByDay(forDays days: Int) -> [(date: Date, duration: TimeInterval)] {
        let calendar = Calendar.current
        var result: [(Date, TimeInterval)] = []

        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayStart = calendar.startOfDay(for: date)

            let dayJourneys = completedJourneys.filter { journey in
                guard let completedAt = journey.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: dayStart)
            }

            let totalDuration = dayJourneys.reduce(0) { $0 + ($1.actualDuration ?? $1.scheduledDuration) }
            result.append((dayStart, totalDuration))
        }

        return result
    }

    // MARK: - Persistence

    private func save() {
        let encoder = JSONEncoder()

        if let journeysData = try? encoder.encode(journeys) {
            UserDefaults.standard.set(journeysData, forKey: journeysKey)
        }

        if let progressData = try? encoder.encode(userProgress) {
            UserDefaults.standard.set(progressData, forKey: progressKey)
        }
    }

    private func load() {
        let decoder = JSONDecoder()

        if let journeysData = UserDefaults.standard.data(forKey: journeysKey),
           let decoded = try? decoder.decode([Journey].self, from: journeysData) {
            journeys = decoded
        }

        if let progressData = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? decoder.decode(UserProgress.self, from: progressData) {
            userProgress = decoded
        }
    }

    // MARK: - Debug

    func clearAll() {
        journeys = []
        userProgress = UserProgress()
        save()
    }
}
