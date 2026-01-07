//
//  Station.swift
//  RailFocus
//
//  Train station data model for European high-speed rail lines
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
    let countryFlag: String

    init(
        id: UUID = UUID(),
        name: String,
        code: String,
        city: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String = "UTC",
        railLine: String = "",
        countryFlag: String = "🇪🇺"
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.city = city
        self.country = country
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.timezone = timezone
        self.railLine = railLine
        self.countryFlag = countryFlag
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

// MARK: - Train Route

struct TrainRoute: Identifiable {
    let id = UUID()
    let name: String
    let railLine: String
    let stations: [Station]
    let color: String // Hex color for route display

    var waypoints: [CLLocationCoordinate2D] {
        stations.map { $0.locationCoordinate }
    }
}

// MARK: - European High-Speed Rail Stations

extension Station {
    // MARK: - France (TGV)
    static let parisGareDeLyon = Station(
        name: "Paris Gare de Lyon",
        code: "PLY",
        city: "Paris",
        country: "France",
        latitude: 48.8443,
        longitude: 2.3743,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    static let parisGareDeNord = Station(
        name: "Paris Gare du Nord",
        code: "PGN",
        city: "Paris",
        country: "France",
        latitude: 48.8809,
        longitude: 2.3553,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    static let lyonPartDieu = Station(
        name: "Lyon Part-Dieu",
        code: "LPD",
        city: "Lyon",
        country: "France",
        latitude: 45.7606,
        longitude: 4.8594,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    static let marseilleStCharles = Station(
        name: "Marseille Saint-Charles",
        code: "MSC",
        city: "Marseille",
        country: "France",
        latitude: 43.3028,
        longitude: 5.3803,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    static let bordeauxStJean = Station(
        name: "Bordeaux Saint-Jean",
        code: "BSJ",
        city: "Bordeaux",
        country: "France",
        latitude: 44.8256,
        longitude: -0.5567,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    static let strasbourg = Station(
        name: "Strasbourg",
        code: "STR",
        city: "Strasbourg",
        country: "France",
        latitude: 48.5850,
        longitude: 7.7350,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    static let nice = Station(
        name: "Nice Ville",
        code: "NCE",
        city: "Nice",
        country: "France",
        latitude: 43.7044,
        longitude: 7.2619,
        timezone: "Europe/Paris",
        railLine: "TGV",
        countryFlag: "🇫🇷"
    )

    // MARK: - United Kingdom (Eurostar)
    static let londonStPancras = Station(
        name: "London St Pancras",
        code: "STP",
        city: "London",
        country: "United Kingdom",
        latitude: 51.5322,
        longitude: -0.1260,
        timezone: "Europe/London",
        railLine: "Eurostar",
        countryFlag: "🇬🇧"
    )

    // MARK: - Belgium (Eurostar/Thalys)
    static let brusselsMidi = Station(
        name: "Bruxelles-Midi",
        code: "BRU",
        city: "Brussels",
        country: "Belgium",
        latitude: 50.8354,
        longitude: 4.3365,
        timezone: "Europe/Brussels",
        railLine: "Eurostar",
        countryFlag: "🇧🇪"
    )

    static let antwerpen = Station(
        name: "Antwerpen-Centraal",
        code: "ANT",
        city: "Antwerp",
        country: "Belgium",
        latitude: 51.2172,
        longitude: 4.4211,
        timezone: "Europe/Brussels",
        railLine: "Thalys",
        countryFlag: "🇧🇪"
    )

    // MARK: - Netherlands (Eurostar/Thalys)
    static let amsterdamCentraal = Station(
        name: "Amsterdam Centraal",
        code: "AMS",
        city: "Amsterdam",
        country: "Netherlands",
        latitude: 52.3791,
        longitude: 4.9003,
        timezone: "Europe/Amsterdam",
        railLine: "Eurostar",
        countryFlag: "🇳🇱"
    )

    static let rotterdam = Station(
        name: "Rotterdam Centraal",
        code: "RTD",
        city: "Rotterdam",
        country: "Netherlands",
        latitude: 51.9244,
        longitude: 4.4690,
        timezone: "Europe/Amsterdam",
        railLine: "Thalys",
        countryFlag: "🇳🇱"
    )

    // MARK: - Germany (ICE)
    static let berlinHbf = Station(
        name: "Berlin Hauptbahnhof",
        code: "BER",
        city: "Berlin",
        country: "Germany",
        latitude: 52.5250,
        longitude: 13.3694,
        timezone: "Europe/Berlin",
        railLine: "ICE",
        countryFlag: "🇩🇪"
    )

    static let frankfurtHbf = Station(
        name: "Frankfurt Hauptbahnhof",
        code: "FRA",
        city: "Frankfurt",
        country: "Germany",
        latitude: 50.1072,
        longitude: 8.6638,
        timezone: "Europe/Berlin",
        railLine: "ICE",
        countryFlag: "🇩🇪"
    )

    static let munichHbf = Station(
        name: "München Hauptbahnhof",
        code: "MUC",
        city: "Munich",
        country: "Germany",
        latitude: 48.1403,
        longitude: 11.5600,
        timezone: "Europe/Berlin",
        railLine: "ICE",
        countryFlag: "🇩🇪"
    )

    static let cologneHbf = Station(
        name: "Köln Hauptbahnhof",
        code: "CGN",
        city: "Cologne",
        country: "Germany",
        latitude: 50.9430,
        longitude: 6.9589,
        timezone: "Europe/Berlin",
        railLine: "ICE",
        countryFlag: "🇩🇪"
    )

    static let hamburgHbf = Station(
        name: "Hamburg Hauptbahnhof",
        code: "HAM",
        city: "Hamburg",
        country: "Germany",
        latitude: 53.5530,
        longitude: 10.0069,
        timezone: "Europe/Berlin",
        railLine: "ICE",
        countryFlag: "🇩🇪"
    )

    static let stuttgartHbf = Station(
        name: "Stuttgart Hauptbahnhof",
        code: "STU",
        city: "Stuttgart",
        country: "Germany",
        latitude: 48.7847,
        longitude: 9.1816,
        timezone: "Europe/Berlin",
        railLine: "ICE",
        countryFlag: "🇩🇪"
    )

    // MARK: - Spain (AVE)
    static let madridAtocha = Station(
        name: "Madrid Atocha",
        code: "MAD",
        city: "Madrid",
        country: "Spain",
        latitude: 40.4065,
        longitude: -3.6892,
        timezone: "Europe/Madrid",
        railLine: "AVE",
        countryFlag: "🇪🇸"
    )

    static let barcelonaSants = Station(
        name: "Barcelona Sants",
        code: "BCN",
        city: "Barcelona",
        country: "Spain",
        latitude: 41.3793,
        longitude: 2.1404,
        timezone: "Europe/Madrid",
        railLine: "AVE",
        countryFlag: "🇪🇸"
    )

    static let sevillaSantaJusta = Station(
        name: "Sevilla Santa Justa",
        code: "SVQ",
        city: "Seville",
        country: "Spain",
        latitude: 37.3919,
        longitude: -5.9752,
        timezone: "Europe/Madrid",
        railLine: "AVE",
        countryFlag: "🇪🇸"
    )

    static let valencia = Station(
        name: "Valencia Joaquín Sorolla",
        code: "VLC",
        city: "Valencia",
        country: "Spain",
        latitude: 39.4659,
        longitude: -0.3773,
        timezone: "Europe/Madrid",
        railLine: "AVE",
        countryFlag: "🇪🇸"
    )

    // MARK: - Italy (Frecciarossa)
    static let romaTermini = Station(
        name: "Roma Termini",
        code: "ROM",
        city: "Rome",
        country: "Italy",
        latitude: 41.9009,
        longitude: 12.5014,
        timezone: "Europe/Rome",
        railLine: "Frecciarossa",
        countryFlag: "🇮🇹"
    )

    static let milanoCentrale = Station(
        name: "Milano Centrale",
        code: "MIL",
        city: "Milan",
        country: "Italy",
        latitude: 45.4862,
        longitude: 9.2049,
        timezone: "Europe/Rome",
        railLine: "Frecciarossa",
        countryFlag: "🇮🇹"
    )

    static let firenzeSMN = Station(
        name: "Firenze Santa Maria Novella",
        code: "FLR",
        city: "Florence",
        country: "Italy",
        latitude: 43.7764,
        longitude: 11.2477,
        timezone: "Europe/Rome",
        railLine: "Frecciarossa",
        countryFlag: "🇮🇹"
    )

    static let veneziaSL = Station(
        name: "Venezia Santa Lucia",
        code: "VCE",
        city: "Venice",
        country: "Italy",
        latitude: 45.4410,
        longitude: 12.3212,
        timezone: "Europe/Rome",
        railLine: "Frecciarossa",
        countryFlag: "🇮🇹"
    )

    static let napoliCentrale = Station(
        name: "Napoli Centrale",
        code: "NAP",
        city: "Naples",
        country: "Italy",
        latitude: 40.8531,
        longitude: 14.2727,
        timezone: "Europe/Rome",
        railLine: "Frecciarossa",
        countryFlag: "🇮🇹"
    )

    static let bologna = Station(
        name: "Bologna Centrale",
        code: "BLQ",
        city: "Bologna",
        country: "Italy",
        latitude: 44.5058,
        longitude: 11.3426,
        timezone: "Europe/Rome",
        railLine: "Frecciarossa",
        countryFlag: "🇮🇹"
    )

    // MARK: - Switzerland
    static let zurichHB = Station(
        name: "Zürich HB",
        code: "ZRH",
        city: "Zurich",
        country: "Switzerland",
        latitude: 47.3783,
        longitude: 8.5403,
        timezone: "Europe/Zurich",
        railLine: "SBB",
        countryFlag: "🇨🇭"
    )

    static let geneva = Station(
        name: "Genève-Cornavin",
        code: "GVA",
        city: "Geneva",
        country: "Switzerland",
        latitude: 46.2104,
        longitude: 6.1423,
        timezone: "Europe/Zurich",
        railLine: "SBB",
        countryFlag: "🇨🇭"
    )

    // MARK: - Austria
    static let wienHbf = Station(
        name: "Wien Hauptbahnhof",
        code: "VIE",
        city: "Vienna",
        country: "Austria",
        latitude: 48.1855,
        longitude: 16.3780,
        timezone: "Europe/Vienna",
        railLine: "ÖBB",
        countryFlag: "🇦🇹"
    )

    // MARK: - All European Stations
    static let europeStations: [Station] = [
        // France
        parisGareDeLyon, parisGareDeNord, lyonPartDieu, marseilleStCharles,
        bordeauxStJean, strasbourg, nice,
        // UK
        londonStPancras,
        // Belgium
        brusselsMidi, antwerpen,
        // Netherlands
        amsterdamCentraal, rotterdam,
        // Germany
        berlinHbf, frankfurtHbf, munichHbf, cologneHbf, hamburgHbf, stuttgartHbf,
        // Spain
        madridAtocha, barcelonaSants, sevillaSantaJusta, valencia,
        // Italy
        romaTermini, milanoCentrale, firenzeSMN, veneziaSL, napoliCentrale, bologna,
        // Switzerland
        zurichHB, geneva,
        // Austria
        wienHbf
    ]

    // Keep sampleStations for backward compatibility
    static let sampleStations: [Station] = europeStations

    static func find(byCode code: String) -> Station? {
        europeStations.first { $0.code == code }
    }

    // Convenience accessors (updated for Europe)
    static var tokyo: Station { parisGareDeLyon } // Redirect for compatibility
    static var osaka: Station { lyonPartDieu } // Redirect for compatibility
    static var kyoto: Station { marseilleStCharles } // Redirect for compatibility
    static var paris: Station { parisGareDeLyon }
    static var lyon: Station { lyonPartDieu }
    static var london: Station { londonStPancras }
    static var berlin: Station { berlinHbf }

    // Get stations by rail line
    static func stations(forLine line: String) -> [Station] {
        europeStations.filter { $0.railLine == line }
    }

    // Get stations by country
    static func stations(forCountry country: String) -> [Station] {
        europeStations.filter { $0.country == country }
    }

    static var railLines: [String] {
        Array(Set(europeStations.map { $0.railLine })).sorted()
    }

    static var countries: [String] {
        Array(Set(europeStations.map { $0.country })).sorted()
    }
}

// MARK: - European Train Routes

extension TrainRoute {
    // Eurostar: London - Paris - Brussels - Amsterdam
    static let eurostar = TrainRoute(
        name: "Eurostar",
        railLine: "Eurostar",
        stations: [.londonStPancras, .parisGareDeNord, .brusselsMidi, .amsterdamCentraal],
        color: "FFCD00"
    )

    // TGV Sud-Est: Paris - Lyon - Marseille
    static let tgvSudEst = TrainRoute(
        name: "TGV Sud-Est",
        railLine: "TGV",
        stations: [.parisGareDeLyon, .lyonPartDieu, .marseilleStCharles, .nice],
        color: "9B2335"
    )

    // TGV Atlantique: Paris - Bordeaux
    static let tgvAtlantique = TrainRoute(
        name: "TGV Atlantique",
        railLine: "TGV",
        stations: [.parisGareDeLyon, .bordeauxStJean],
        color: "9B2335"
    )

    // ICE Frankfurt - Berlin
    static let iceBerlin = TrainRoute(
        name: "ICE Berlin",
        railLine: "ICE",
        stations: [.frankfurtHbf, .berlinHbf],
        color: "EC0016"
    )

    // ICE Frankfurt - Munich
    static let iceMunich = TrainRoute(
        name: "ICE Munich",
        railLine: "ICE",
        stations: [.frankfurtHbf, .stuttgartHbf, .munichHbf],
        color: "EC0016"
    )

    // ICE Hamburg - Cologne
    static let iceWest = TrainRoute(
        name: "ICE West",
        railLine: "ICE",
        stations: [.hamburgHbf, .cologneHbf, .frankfurtHbf],
        color: "EC0016"
    )

    // AVE Madrid - Barcelona
    static let aveNordeste = TrainRoute(
        name: "AVE Nordeste",
        railLine: "AVE",
        stations: [.madridAtocha, .barcelonaSants],
        color: "6B2C91"
    )

    // AVE Madrid - Seville
    static let aveSur = TrainRoute(
        name: "AVE Sur",
        railLine: "AVE",
        stations: [.madridAtocha, .sevillaSantaJusta],
        color: "6B2C91"
    )

    // Frecciarossa Milan - Rome - Naples
    static let frecciarossaNord = TrainRoute(
        name: "Frecciarossa",
        railLine: "Frecciarossa",
        stations: [.milanoCentrale, .bologna, .firenzeSMN, .romaTermini, .napoliCentrale],
        color: "C8102E"
    )

    // Frecciarossa Milan - Venice
    static let frecciarossaVenezia = TrainRoute(
        name: "Frecciarossa Venezia",
        railLine: "Frecciarossa",
        stations: [.milanoCentrale, .veneziaSL],
        color: "C8102E"
    )

    // Thalys Paris - Brussels - Amsterdam
    static let thalys = TrainRoute(
        name: "Thalys",
        railLine: "Thalys",
        stations: [.parisGareDeNord, .brusselsMidi, .antwerpen, .rotterdam, .amsterdamCentraal],
        color: "9B2335"
    )

    // Cross-border: Paris - Zurich
    static let tgvLyria = TrainRoute(
        name: "TGV Lyria",
        railLine: "TGV",
        stations: [.parisGareDeLyon, .zurichHB],
        color: "9B2335"
    )

    // All routes
    static let allRoutes: [TrainRoute] = [
        eurostar, tgvSudEst, tgvAtlantique,
        iceBerlin, iceMunich, iceWest,
        aveNordeste, aveSur,
        frecciarossaNord, frecciarossaVenezia,
        thalys, tgvLyria
    ]

    // Find route between two stations
    static func findRoute(from origin: Station, to destination: Station) -> TrainRoute? {
        allRoutes.first { route in
            let originIndex = route.stations.firstIndex(of: origin)
            let destIndex = route.stations.firstIndex(of: destination)
            return originIndex != nil && destIndex != nil
        }
    }

    // Get available destinations from a station
    static func availableDestinations(from station: Station) -> [Station] {
        var destinations: Set<Station> = []
        for route in allRoutes {
            if route.stations.contains(station) {
                for s in route.stations where s != station {
                    destinations.insert(s)
                }
            }
        }
        return Array(destinations).sorted { $0.city < $1.city }
    }
}

// MARK: - Rail Connection (with real travel times)

struct RailConnection: Identifiable {
    let id = UUID()
    let from: Station
    let to: Station
    let travelTimeMinutes: Int
    let railLine: String
    let trainService: String // e.g., "Eurostar", "TGV inOui", "ICE Sprinter"

    var formattedTime: String {
        let hours = travelTimeMinutes / 60
        let minutes = travelTimeMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Real European Rail Connections

extension RailConnection {
    // Real travel times based on actual high-speed rail schedules
    static let allConnections: [RailConnection] = [
        // Eurostar connections (London)
        RailConnection(from: .londonStPancras, to: .parisGareDeNord, travelTimeMinutes: 136, railLine: "Eurostar", trainService: "Eurostar"),
        RailConnection(from: .londonStPancras, to: .brusselsMidi, travelTimeMinutes: 121, railLine: "Eurostar", trainService: "Eurostar"),
        RailConnection(from: .londonStPancras, to: .amsterdamCentraal, travelTimeMinutes: 223, railLine: "Eurostar", trainService: "Eurostar"),

        // TGV connections (Paris)
        RailConnection(from: .parisGareDeLyon, to: .lyonPartDieu, travelTimeMinutes: 120, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .parisGareDeLyon, to: .marseilleStCharles, travelTimeMinutes: 190, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .parisGareDeLyon, to: .nice, travelTimeMinutes: 330, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .parisGareDeLyon, to: .bordeauxStJean, travelTimeMinutes: 125, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .parisGareDeLyon, to: .strasbourg, travelTimeMinutes: 106, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .parisGareDeLyon, to: .zurichHB, travelTimeMinutes: 244, railLine: "TGV", trainService: "TGV Lyria"),
        RailConnection(from: .parisGareDeLyon, to: .geneva, travelTimeMinutes: 188, railLine: "TGV", trainService: "TGV Lyria"),
        RailConnection(from: .parisGareDeLyon, to: .milanoCentrale, travelTimeMinutes: 420, railLine: "TGV", trainService: "TGV"),

        // Thalys/Eurostar (Paris Nord)
        RailConnection(from: .parisGareDeNord, to: .brusselsMidi, travelTimeMinutes: 82, railLine: "Thalys", trainService: "Thalys"),
        RailConnection(from: .parisGareDeNord, to: .amsterdamCentraal, travelTimeMinutes: 195, railLine: "Thalys", trainService: "Thalys"),
        RailConnection(from: .parisGareDeNord, to: .cologneHbf, travelTimeMinutes: 220, railLine: "Thalys", trainService: "Thalys"),

        // Lyon connections
        RailConnection(from: .lyonPartDieu, to: .marseilleStCharles, travelTimeMinutes: 100, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .lyonPartDieu, to: .nice, travelTimeMinutes: 270, railLine: "TGV", trainService: "TGV inOui"),
        RailConnection(from: .lyonPartDieu, to: .geneva, travelTimeMinutes: 108, railLine: "TGV", trainService: "TGV Lyria"),

        // Brussels connections
        RailConnection(from: .brusselsMidi, to: .amsterdamCentraal, travelTimeMinutes: 113, railLine: "Thalys", trainService: "Thalys"),
        RailConnection(from: .brusselsMidi, to: .cologneHbf, travelTimeMinutes: 107, railLine: "Thalys", trainService: "Thalys"),
        RailConnection(from: .brusselsMidi, to: .frankfurtHbf, travelTimeMinutes: 180, railLine: "ICE", trainService: "ICE"),

        // ICE connections (Germany)
        RailConnection(from: .frankfurtHbf, to: .berlinHbf, travelTimeMinutes: 240, railLine: "ICE", trainService: "ICE Sprinter"),
        RailConnection(from: .frankfurtHbf, to: .munichHbf, travelTimeMinutes: 190, railLine: "ICE", trainService: "ICE"),
        RailConnection(from: .frankfurtHbf, to: .cologneHbf, travelTimeMinutes: 62, railLine: "ICE", trainService: "ICE Sprinter"),
        RailConnection(from: .frankfurtHbf, to: .stuttgartHbf, travelTimeMinutes: 75, railLine: "ICE", trainService: "ICE"),
        RailConnection(from: .frankfurtHbf, to: .hamburgHbf, travelTimeMinutes: 225, railLine: "ICE", trainService: "ICE"),
        RailConnection(from: .berlinHbf, to: .hamburgHbf, travelTimeMinutes: 107, railLine: "ICE", trainService: "ICE Sprinter"),
        RailConnection(from: .berlinHbf, to: .munichHbf, travelTimeMinutes: 240, railLine: "ICE", trainService: "ICE"),
        RailConnection(from: .munichHbf, to: .stuttgartHbf, travelTimeMinutes: 130, railLine: "ICE", trainService: "ICE"),
        RailConnection(from: .cologneHbf, to: .hamburgHbf, travelTimeMinutes: 240, railLine: "ICE", trainService: "ICE"),

        // AVE connections (Spain)
        RailConnection(from: .madridAtocha, to: .barcelonaSants, travelTimeMinutes: 155, railLine: "AVE", trainService: "AVE"),
        RailConnection(from: .madridAtocha, to: .sevillaSantaJusta, travelTimeMinutes: 140, railLine: "AVE", trainService: "AVE"),
        RailConnection(from: .madridAtocha, to: .valencia, travelTimeMinutes: 100, railLine: "AVE", trainService: "AVE"),
        RailConnection(from: .barcelonaSants, to: .valencia, travelTimeMinutes: 170, railLine: "AVE", trainService: "AVE"),
        RailConnection(from: .barcelonaSants, to: .parisGareDeLyon, travelTimeMinutes: 380, railLine: "AVE", trainService: "AVE International"),

        // Frecciarossa connections (Italy)
        RailConnection(from: .milanoCentrale, to: .romaTermini, travelTimeMinutes: 175, railLine: "Frecciarossa", trainService: "Frecciarossa 1000"),
        RailConnection(from: .milanoCentrale, to: .firenzeSMN, travelTimeMinutes: 95, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .milanoCentrale, to: .veneziaSL, travelTimeMinutes: 145, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .milanoCentrale, to: .napoliCentrale, travelTimeMinutes: 275, railLine: "Frecciarossa", trainService: "Frecciarossa 1000"),
        RailConnection(from: .milanoCentrale, to: .bologna, travelTimeMinutes: 65, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .romaTermini, to: .napoliCentrale, travelTimeMinutes: 70, railLine: "Frecciarossa", trainService: "Frecciarossa 1000"),
        RailConnection(from: .romaTermini, to: .firenzeSMN, travelTimeMinutes: 95, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .romaTermini, to: .veneziaSL, travelTimeMinutes: 225, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .firenzeSMN, to: .veneziaSL, travelTimeMinutes: 125, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .firenzeSMN, to: .bologna, travelTimeMinutes: 35, railLine: "Frecciarossa", trainService: "Frecciarossa"),
        RailConnection(from: .bologna, to: .veneziaSL, travelTimeMinutes: 90, railLine: "Frecciarossa", trainService: "Frecciarossa"),

        // Swiss connections
        RailConnection(from: .zurichHB, to: .geneva, travelTimeMinutes: 170, railLine: "SBB", trainService: "IC"),
        RailConnection(from: .zurichHB, to: .milanoCentrale, travelTimeMinutes: 195, railLine: "SBB", trainService: "EC"),
        RailConnection(from: .zurichHB, to: .munichHbf, travelTimeMinutes: 240, railLine: "SBB", trainService: "EC"),

        // Austria connections
        RailConnection(from: .wienHbf, to: .munichHbf, travelTimeMinutes: 240, railLine: "ÖBB", trainService: "Railjet"),
        RailConnection(from: .wienHbf, to: .zurichHB, travelTimeMinutes: 480, railLine: "ÖBB", trainService: "Railjet"),
        RailConnection(from: .wienHbf, to: .veneziaSL, travelTimeMinutes: 420, railLine: "ÖBB", trainService: "EC"),
    ]

    // Get connections from a specific station
    static func connections(from station: Station) -> [RailConnection] {
        allConnections.filter { $0.from == station }
    }

    // Get connection between two stations
    static func connection(from origin: Station, to destination: Station) -> RailConnection? {
        allConnections.first { $0.from == origin && $0.to == destination } ??
        allConnections.first { $0.from == destination && $0.to == origin }
    }

    // Get all destinations reachable from a station with travel times
    static func destinations(from station: Station) -> [(station: Station, connection: RailConnection)] {
        let outgoing = allConnections.filter { $0.from == station }.map { ($0.to, $0) }
        let incoming = allConnections.filter { $0.to == station }.map { ($0.from, $0) }
        return (outgoing + incoming).sorted { $0.1.travelTimeMinutes < $1.1.travelTimeMinutes }
    }
}
