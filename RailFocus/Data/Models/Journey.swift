//
//  Journey.swift
//  RailFocus
//
//  Core train journey data model
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Journey Status

enum JourneyStatus: String, Codable {
    case scheduled
    case inProgress
    case completed
    case interrupted
    case cancelled

    var displayText: String {
        switch self {
        case .scheduled: return "SCHEDULED"
        case .inProgress: return "EN ROUTE"
        case .completed: return "ARRIVED"
        case .interrupted: return "INTERRUPTED"
        case .cancelled: return "CANCELLED"
        }
    }
}

// MARK: - Journey Model

struct Journey: Identifiable, Codable {
    let id: UUID
    var originStation: Station
    var destinationStation: Station
    var scheduledDuration: TimeInterval
    var actualDuration: TimeInterval?
    var status: JourneyStatus
    var startedAt: Date?
    var completedAt: Date?
    var tag: FocusTag?
    var notes: String?
    var carNumber: String
    var trainName: String

    init(
        id: UUID = UUID(),
        origin: Station,
        destination: Station,
        duration: TimeInterval,
        tag: FocusTag? = nil
    ) {
        self.id = id
        self.originStation = origin
        self.destinationStation = destination
        self.scheduledDuration = duration
        self.status = .scheduled
        self.tag = tag
        self.carNumber = Journey.generateCarNumber()
        self.trainName = Journey.generateTrainName(from: origin)
    }

    // MARK: - Computed Properties

    var distanceKm: Double {
        let origin = CLLocation(
            latitude: originStation.coordinate.latitude,
            longitude: originStation.coordinate.longitude
        )
        let destination = CLLocation(
            latitude: destinationStation.coordinate.latitude,
            longitude: destinationStation.coordinate.longitude
        )
        return origin.distance(from: destination) / 1000
    }

    var distanceMiles: Double {
        distanceKm * 0.621371
    }

    var routeCode: String {
        "\(originStation.code) → \(destinationStation.code)"
    }

    var formattedDuration: String {
        let minutes = Int(scheduledDuration / 60)
        return "\(minutes)m"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: startedAt ?? Date())
    }

    var progress: Double {
        guard status == .inProgress, let startedAt = startedAt else {
            return status == .completed ? 1.0 : 0.0
        }
        let elapsed = Date().timeIntervalSince(startedAt)
        return min(elapsed / scheduledDuration, 1.0)
    }

    // MARK: - Helpers

    private static func generateCarNumber() -> String {
        let car = Int.random(in: 1...12)
        let seat = Int.random(in: 1...80)
        return "Car \(car), Seat \(seat)"
    }

    private static func generateTrainName(from station: Station) -> String {
        let trainNumbers = [
            "Shinkansen": ["Nozomi", "Hikari", "Kodama"],
            "TGV": ["TGV inOui", "TGV Lyria", "Ouigo"],
            "ICE": ["ICE", "ICE Sprinter"],
            "Eurostar": ["Eurostar"],
            "AVE": ["AVE", "Avlo"],
            "CRH": ["Fuxing", "Harmony"]
        ]

        let names = trainNumbers[station.railLine] ?? ["Express"]
        let name = names.randomElement() ?? "Express"
        let number = Int.random(in: 100...999)
        return "\(name) \(number)"
    }

    /// Estimated speed based on high-speed rail (thematic, not literal)
    var currentSpeed: Int {
        guard status == .inProgress else { return 0 }
        // High-speed trains typically run 250-350 km/h
        return Int.random(in: 280...320)
    }

    // MARK: - Actions

    mutating func start() {
        status = .inProgress
        startedAt = Date()
    }

    mutating func complete() {
        status = .completed
        completedAt = Date()
        if let startedAt = startedAt {
            actualDuration = Date().timeIntervalSince(startedAt)
        }
    }

    mutating func interrupt() {
        status = .interrupted
        completedAt = Date()
        if let startedAt = startedAt {
            actualDuration = Date().timeIntervalSince(startedAt)
        }
    }
}

// MARK: - Focus Tag

enum FocusTag: String, Codable, CaseIterable, Identifiable {
    case work
    case study
    case coding
    case writing
    case admin
    case personal

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .writing: return "pencil"
        case .admin: return "folder.fill"
        case .personal: return "person.fill"
        }
    }

    var color: Color {
        switch self {
        case .work: return .rfElectricBlue
        case .study: return .rfEmerald
        case .coding: return .rfCrimson
        case .writing: return .orange
        case .admin: return .purple
        case .personal: return .cyan
        }
    }
}
