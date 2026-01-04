//
//  Station.swift
//  RailFocus
//
//  Station/Airport data model
//

import Foundation
import CoreLocation

// MARK: - Station Model

struct Station: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let code: String
    let city: String
    let country: String
    let coordinate: Coordinate
    let timezone: String

    init(
        id: UUID = UUID(),
        name: String,
        code: String,
        city: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String = "UTC"
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.city = city
        self.country = country
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.timezone = timezone
    }

    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}

// MARK: - Coordinate (Codable wrapper)

struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Sample Stations

extension Station {
    static let sampleStations: [Station] = [
        // Europe
        Station(
            name: "London Heathrow",
            code: "LHR",
            city: "London",
            country: "United Kingdom",
            latitude: 51.4700,
            longitude: -0.4543,
            timezone: "Europe/London"
        ),
        Station(
            name: "Paris Charles de Gaulle",
            code: "CDG",
            city: "Paris",
            country: "France",
            latitude: 49.0097,
            longitude: 2.5479,
            timezone: "Europe/Paris"
        ),
        Station(
            name: "Frankfurt Airport",
            code: "FRA",
            city: "Frankfurt",
            country: "Germany",
            latitude: 50.0379,
            longitude: 8.5622,
            timezone: "Europe/Berlin"
        ),
        Station(
            name: "Amsterdam Schiphol",
            code: "AMS",
            city: "Amsterdam",
            country: "Netherlands",
            latitude: 52.3105,
            longitude: 4.7683,
            timezone: "Europe/Amsterdam"
        ),

        // North America
        Station(
            name: "Chicago O'Hare",
            code: "ORD",
            city: "Chicago",
            country: "United States",
            latitude: 41.9742,
            longitude: -87.9073,
            timezone: "America/Chicago"
        ),
        Station(
            name: "New York JFK",
            code: "JFK",
            city: "New York",
            country: "United States",
            latitude: 40.6413,
            longitude: -73.7781,
            timezone: "America/New_York"
        ),
        Station(
            name: "Los Angeles International",
            code: "LAX",
            city: "Los Angeles",
            country: "United States",
            latitude: 33.9416,
            longitude: -118.4085,
            timezone: "America/Los_Angeles"
        ),
        Station(
            name: "San Francisco International",
            code: "SFO",
            city: "San Francisco",
            country: "United States",
            latitude: 37.6213,
            longitude: -122.3790,
            timezone: "America/Los_Angeles"
        ),

        // Asia
        Station(
            name: "Tokyo Narita",
            code: "NRT",
            city: "Tokyo",
            country: "Japan",
            latitude: 35.7720,
            longitude: 140.3929,
            timezone: "Asia/Tokyo"
        ),
        Station(
            name: "Singapore Changi",
            code: "SIN",
            city: "Singapore",
            country: "Singapore",
            latitude: 1.3644,
            longitude: 103.9915,
            timezone: "Asia/Singapore"
        ),
        Station(
            name: "Dubai International",
            code: "DXB",
            city: "Dubai",
            country: "United Arab Emirates",
            latitude: 25.2532,
            longitude: 55.3657,
            timezone: "Asia/Dubai"
        ),
        Station(
            name: "Hong Kong International",
            code: "HKG",
            city: "Hong Kong",
            country: "China",
            latitude: 22.3080,
            longitude: 113.9185,
            timezone: "Asia/Hong_Kong"
        )
    ]

    static func find(byCode code: String) -> Station? {
        sampleStations.first { $0.code == code }
    }

    static var london: Station { sampleStations[0] }
    static var paris: Station { sampleStations[1] }
    static var chicago: Station { sampleStations[4] }
    static var newYork: Station { sampleStations[5] }
    static var tokyo: Station { sampleStations[8] }
}
