//
//  Station.swift
//  RailFocus
//
//  Train station data model for high-speed rail lines
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
    let railLine: String

    init(
        id: UUID = UUID(),
        name: String,
        code: String,
        city: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String = "UTC",
        railLine: String = ""
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.city = city
        self.country = country
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.timezone = timezone
        self.railLine = railLine
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

// MARK: - Sample Train Stations (Real High-Speed Rail)

extension Station {
    static let sampleStations: [Station] = [
        // Japan - Shinkansen (Tokaido Line)
        Station(
            name: "Tokyo Station",
            code: "TYO",
            city: "Tokyo",
            country: "Japan",
            latitude: 35.6812,
            longitude: 139.7671,
            timezone: "Asia/Tokyo",
            railLine: "Shinkansen"
        ),
        Station(
            name: "Shin-Osaka Station",
            code: "OSA",
            city: "Osaka",
            country: "Japan",
            latitude: 34.7334,
            longitude: 135.5001,
            timezone: "Asia/Tokyo",
            railLine: "Shinkansen"
        ),
        Station(
            name: "Kyoto Station",
            code: "KYO",
            city: "Kyoto",
            country: "Japan",
            latitude: 34.9856,
            longitude: 135.7585,
            timezone: "Asia/Tokyo",
            railLine: "Shinkansen"
        ),
        Station(
            name: "Nagoya Station",
            code: "NGY",
            city: "Nagoya",
            country: "Japan",
            latitude: 35.1709,
            longitude: 136.8815,
            timezone: "Asia/Tokyo",
            railLine: "Shinkansen"
        ),

        // France - TGV
        Station(
            name: "Paris Gare de Lyon",
            code: "PLY",
            city: "Paris",
            country: "France",
            latitude: 48.8443,
            longitude: 2.3743,
            timezone: "Europe/Paris",
            railLine: "TGV"
        ),
        Station(
            name: "Lyon Part-Dieu",
            code: "LPD",
            city: "Lyon",
            country: "France",
            latitude: 45.7606,
            longitude: 4.8594,
            timezone: "Europe/Paris",
            railLine: "TGV"
        ),
        Station(
            name: "Marseille Saint-Charles",
            code: "MSC",
            city: "Marseille",
            country: "France",
            latitude: 43.3028,
            longitude: 5.3803,
            timezone: "Europe/Paris",
            railLine: "TGV"
        ),

        // UK - Eurostar / HS1
        Station(
            name: "London St Pancras",
            code: "STP",
            city: "London",
            country: "United Kingdom",
            latitude: 51.5322,
            longitude: -0.1260,
            timezone: "Europe/London",
            railLine: "Eurostar"
        ),

        // Germany - ICE
        Station(
            name: "Berlin Hauptbahnhof",
            code: "BHB",
            city: "Berlin",
            country: "Germany",
            latitude: 52.5250,
            longitude: 13.3694,
            timezone: "Europe/Berlin",
            railLine: "ICE"
        ),
        Station(
            name: "Frankfurt Hauptbahnhof",
            code: "FHB",
            city: "Frankfurt",
            country: "Germany",
            latitude: 50.1072,
            longitude: 8.6638,
            timezone: "Europe/Berlin",
            railLine: "ICE"
        ),
        Station(
            name: "Munich Hauptbahnhof",
            code: "MHB",
            city: "Munich",
            country: "Germany",
            latitude: 48.1403,
            longitude: 11.5600,
            timezone: "Europe/Berlin",
            railLine: "ICE"
        ),

        // Spain - AVE
        Station(
            name: "Madrid Atocha",
            code: "MAT",
            city: "Madrid",
            country: "Spain",
            latitude: 40.4065,
            longitude: -3.6892,
            timezone: "Europe/Madrid",
            railLine: "AVE"
        ),
        Station(
            name: "Barcelona Sants",
            code: "BSA",
            city: "Barcelona",
            country: "Spain",
            latitude: 41.3793,
            longitude: 2.1404,
            timezone: "Europe/Madrid",
            railLine: "AVE"
        ),

        // China - CRH
        Station(
            name: "Beijing South",
            code: "BJS",
            city: "Beijing",
            country: "China",
            latitude: 39.8652,
            longitude: 116.3785,
            timezone: "Asia/Shanghai",
            railLine: "CRH"
        ),
        Station(
            name: "Shanghai Hongqiao",
            code: "SHH",
            city: "Shanghai",
            country: "China",
            latitude: 31.1944,
            longitude: 121.3200,
            timezone: "Asia/Shanghai",
            railLine: "CRH"
        )
    ]

    static func find(byCode code: String) -> Station? {
        sampleStations.first { $0.code == code }
    }

    // Convenience accessors
    static var tokyo: Station { sampleStations[0] }
    static var osaka: Station { sampleStations[1] }
    static var kyoto: Station { sampleStations[2] }
    static var paris: Station { sampleStations[4] }
    static var lyon: Station { sampleStations[5] }
    static var london: Station { sampleStations[7] }
    static var berlin: Station { sampleStations[8] }

    // Get stations by rail line
    static func stations(forLine line: String) -> [Station] {
        sampleStations.filter { $0.railLine == line }
    }

    static var railLines: [String] {
        Array(Set(sampleStations.map { $0.railLine })).sorted()
    }
}
