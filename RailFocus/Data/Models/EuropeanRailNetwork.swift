//
//  EuropeanRailNetwork.swift
//  RailFocus
//
//  Detailed European rail network with realistic waypoints
//

import Foundation
import CoreLocation

// MARK: - Rail Line Definition

struct RailLine: Identifiable {
    let id = UUID()
    let name: String
    let color: String // Hex color
    let waypoints: [CLLocationCoordinate2D]

    // Convenience for creating coordinates
    static func coord(_ lat: Double, _ lon: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - European Rail Network

struct EuropeanRailNetwork {

    // All rail lines for display on map
    static let allLines: [RailLine] = [
        // Western Europe
        eurostar,
        thalys,
        tgvNord,
        tgvSudEst,
        tgvAtlantique,
        tgvEst,

        // Germany
        iceNorthSouth,
        iceEastWest,
        iceBerlinMunich,
        iceRhineMain,

        // Spain
        aveMadridBarcelona,
        aveMadridSeville,
        aveMadridValencia,

        // Italy
        frecciarossaNorthSouth,
        frecciarossaMilanVenice,

        // Switzerland & Austria
        sbbMainLine,
        obbWestbahn,

        // Scandinavia
        swedenMainLine,
        norwayOsloLine,

        // Eastern Europe
        polandMainLine,
        czechMainLine
    ]

    // MARK: - Eurostar (London - Paris - Brussels - Amsterdam)

    static let eurostar = RailLine(
        name: "Eurostar",
        color: "4A90D9", // Blue
        waypoints: [
            // London St Pancras
            RailLine.coord(51.5322, -0.1260),
            // Through Kent
            RailLine.coord(51.3500, 0.4500),
            // Ashford
            RailLine.coord(51.1500, 0.8700),
            // Channel Tunnel entrance
            RailLine.coord(51.1000, 1.1500),
            // Channel Tunnel exit (Calais)
            RailLine.coord(50.9200, 1.8000),
            // Lille
            RailLine.coord(50.6380, 3.0700),
            // Paris Gare du Nord
            RailLine.coord(48.8809, 2.3553),
        ]
    )

    // MARK: - Thalys (Paris - Brussels - Amsterdam)

    static let thalys = RailLine(
        name: "Thalys",
        color: "4A90D9",
        waypoints: [
            // Paris Gare du Nord
            RailLine.coord(48.8809, 2.3553),
            // North of Paris
            RailLine.coord(49.2500, 2.5000),
            // Belgian border
            RailLine.coord(50.1000, 3.4000),
            // Brussels Midi
            RailLine.coord(50.8354, 4.3365),
            // Antwerp
            RailLine.coord(51.2172, 4.4211),
            // Rotterdam
            RailLine.coord(51.9244, 4.4690),
            // Amsterdam
            RailLine.coord(52.3791, 4.9003),
        ]
    )

    // MARK: - TGV Nord (Paris - Lille)

    static let tgvNord = RailLine(
        name: "TGV Nord",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(48.8809, 2.3553), // Paris
            RailLine.coord(49.2500, 2.5000),
            RailLine.coord(49.8500, 2.8000),
            RailLine.coord(50.6380, 3.0700), // Lille
        ]
    )

    // MARK: - TGV Sud-Est (Paris - Lyon - Marseille - Nice)

    static let tgvSudEst = RailLine(
        name: "TGV Sud-Est",
        color: "4A90D9",
        waypoints: [
            // Paris Gare de Lyon
            RailLine.coord(48.8443, 2.3743),
            // South of Paris
            RailLine.coord(48.4000, 2.7000),
            // Dijon area
            RailLine.coord(47.3200, 5.0400),
            // Mâcon
            RailLine.coord(46.3000, 4.8300),
            // Lyon Part-Dieu
            RailLine.coord(45.7606, 4.8594),
            // Valence
            RailLine.coord(44.9250, 4.9000),
            // Avignon
            RailLine.coord(43.9420, 4.8060),
            // Marseille
            RailLine.coord(43.3028, 5.3803),
            // Toulon
            RailLine.coord(43.1230, 5.9280),
            // Nice
            RailLine.coord(43.7044, 7.2619),
        ]
    )

    // MARK: - TGV Atlantique (Paris - Bordeaux)

    static let tgvAtlantique = RailLine(
        name: "TGV Atlantique",
        color: "4A90D9",
        waypoints: [
            // Paris Montparnasse area
            RailLine.coord(48.8400, 2.3200),
            // Chartres area
            RailLine.coord(48.4500, 1.5000),
            // Tours
            RailLine.coord(47.3900, 0.6900),
            // Poitiers
            RailLine.coord(46.5800, 0.3400),
            // Angoulême
            RailLine.coord(45.6500, 0.1600),
            // Bordeaux
            RailLine.coord(44.8256, -0.5567),
        ]
    )

    // MARK: - TGV Est (Paris - Strasbourg)

    static let tgvEst = RailLine(
        name: "TGV Est",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(48.8767, 2.3590), // Paris Est
            RailLine.coord(48.9500, 3.5000),
            RailLine.coord(49.0500, 4.0300), // Reims area
            RailLine.coord(48.9700, 5.5000),
            RailLine.coord(48.7500, 6.1800), // Nancy
            RailLine.coord(48.5850, 7.7350), // Strasbourg
        ]
    )

    // MARK: - ICE North-South (Hamburg - Frankfurt)

    static let iceNorthSouth = RailLine(
        name: "ICE North-South",
        color: "4A90D9",
        waypoints: [
            // Hamburg
            RailLine.coord(53.5530, 10.0069),
            // Hannover
            RailLine.coord(52.3770, 9.7420),
            // Göttingen
            RailLine.coord(51.5360, 9.9260),
            // Kassel
            RailLine.coord(51.3180, 9.4890),
            // Fulda
            RailLine.coord(50.5540, 9.6840),
            // Frankfurt
            RailLine.coord(50.1072, 8.6638),
        ]
    )

    // MARK: - ICE East-West (Cologne - Berlin)

    static let iceEastWest = RailLine(
        name: "ICE East-West",
        color: "4A90D9",
        waypoints: [
            // Cologne
            RailLine.coord(50.9430, 6.9589),
            // Düsseldorf
            RailLine.coord(51.2200, 6.7940),
            // Essen/Dortmund area
            RailLine.coord(51.5100, 7.4600),
            // Hannover
            RailLine.coord(52.3770, 9.7420),
            // Wolfsburg
            RailLine.coord(52.4230, 10.7870),
            // Berlin
            RailLine.coord(52.5250, 13.3694),
        ]
    )

    // MARK: - ICE Berlin-Munich

    static let iceBerlinMunich = RailLine(
        name: "ICE Berlin-Munich",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(52.5250, 13.3694), // Berlin
            RailLine.coord(51.7500, 12.3000), // Halle area
            RailLine.coord(51.3400, 12.3800), // Leipzig
            RailLine.coord(50.8300, 12.9200), // Chemnitz area
            RailLine.coord(50.0800, 12.1300), // Hof
            RailLine.coord(49.4500, 11.0800), // Nuremberg
            RailLine.coord(48.7850, 11.4200), // Ingolstadt
            RailLine.coord(48.1403, 11.5600), // Munich
        ]
    )

    // MARK: - ICE Rhine-Main (Frankfurt - Cologne)

    static let iceRhineMain = RailLine(
        name: "ICE Rhine-Main",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(50.1072, 8.6638), // Frankfurt
            RailLine.coord(50.0000, 8.2500), // Mainz
            RailLine.coord(50.3600, 7.5900), // Koblenz
            RailLine.coord(50.7300, 7.1000), // Bonn
            RailLine.coord(50.9430, 6.9589), // Cologne
        ]
    )

    // MARK: - AVE Madrid-Barcelona

    static let aveMadridBarcelona = RailLine(
        name: "AVE Madrid-Barcelona",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(40.4065, -3.6892), // Madrid
            RailLine.coord(40.6500, -3.1700), // Guadalajara
            RailLine.coord(41.0700, -1.8200), // Calatayud area
            RailLine.coord(41.6500, -0.8900), // Zaragoza
            RailLine.coord(41.6200, 0.6300), // Lleida
            RailLine.coord(41.2200, 1.5400), // Tarragona area
            RailLine.coord(41.3793, 2.1404), // Barcelona
        ]
    )

    // MARK: - AVE Madrid-Seville

    static let aveMadridSeville = RailLine(
        name: "AVE Madrid-Seville",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(40.4065, -3.6892), // Madrid
            RailLine.coord(39.4700, -3.4200), // Ciudad Real area
            RailLine.coord(38.9800, -3.9300), // Puertollano
            RailLine.coord(38.0000, -4.4800), // Córdoba
            RailLine.coord(37.3919, -5.9752), // Seville
        ]
    )

    // MARK: - AVE Madrid-Valencia

    static let aveMadridValencia = RailLine(
        name: "AVE Madrid-Valencia",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(40.4065, -3.6892), // Madrid
            RailLine.coord(39.8600, -1.4300), // Cuenca
            RailLine.coord(39.4700, -0.3800), // Valencia
        ]
    )

    // MARK: - Frecciarossa North-South (Milan - Rome - Naples)

    static let frecciarossaNorthSouth = RailLine(
        name: "Frecciarossa",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(45.4860, 9.2040), // Milan
            RailLine.coord(45.0500, 9.7000), // Piacenza area
            RailLine.coord(44.4940, 11.3430), // Bologna
            RailLine.coord(43.7740, 11.2540), // Florence
            RailLine.coord(43.0700, 11.7800), // South of Florence
            RailLine.coord(42.4200, 12.1100), // Orvieto area
            RailLine.coord(41.9010, 12.5020), // Rome
            RailLine.coord(41.1390, 14.7800), // Caserta area
            RailLine.coord(40.8530, 14.2720), // Naples
        ]
    )

    // MARK: - Frecciarossa Milan-Venice

    static let frecciarossaMilanVenice = RailLine(
        name: "Frecciarossa Venice",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(45.4860, 9.2040), // Milan
            RailLine.coord(45.4600, 9.9200), // Brescia area
            RailLine.coord(45.4400, 10.9900), // Verona
            RailLine.coord(45.4100, 11.8800), // Padua
            RailLine.coord(45.4410, 12.3200), // Venice
        ]
    )

    // MARK: - SBB Main Line (Zurich - Bern - Geneva)

    static let sbbMainLine = RailLine(
        name: "SBB",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(47.3780, 8.5400), // Zurich
            RailLine.coord(47.0500, 8.3100), // Lucerne area
            RailLine.coord(46.9480, 7.4390), // Bern
            RailLine.coord(46.5200, 6.6300), // Lausanne
            RailLine.coord(46.2100, 6.1400), // Geneva
        ]
    )

    // MARK: - OBB Westbahn (Vienna - Salzburg)

    static let obbWestbahn = RailLine(
        name: "OBB",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(48.2082, 16.3738), // Vienna
            RailLine.coord(48.2000, 15.6200), // St. Pölten
            RailLine.coord(48.2000, 14.2900), // Linz
            RailLine.coord(47.8000, 13.0400), // Salzburg
        ]
    )

    // MARK: - Sweden Main Line (Stockholm - Gothenburg - Malmö)

    static let swedenMainLine = RailLine(
        name: "SJ",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(59.3293, 18.0686), // Stockholm
            RailLine.coord(58.5900, 16.1800), // Norrköping
            RailLine.coord(57.7090, 11.9740), // Gothenburg
            RailLine.coord(56.1600, 12.7000), // Helsingborg
            RailLine.coord(55.6050, 13.0000), // Malmö
            RailLine.coord(55.6720, 12.5650), // Copenhagen (via bridge)
        ]
    )

    // MARK: - Norway Oslo Line

    static let norwayOsloLine = RailLine(
        name: "NSB",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(59.9110, 10.7500), // Oslo
            RailLine.coord(59.2100, 10.9300), // South towards Sweden
            RailLine.coord(58.9700, 11.5300), // Border area
            RailLine.coord(57.7090, 11.9740), // Gothenburg
        ]
    )

    // MARK: - Poland Main Line (Warsaw - Krakow)

    static let polandMainLine = RailLine(
        name: "PKP",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(52.2297, 21.0122), // Warsaw
            RailLine.coord(51.7590, 19.4560), // Łódź
            RailLine.coord(50.8660, 20.6280), // Kielce area
            RailLine.coord(50.0647, 19.9450), // Krakow
        ]
    )

    // MARK: - Czech Main Line (Prague - Vienna)

    static let czechMainLine = RailLine(
        name: "CD",
        color: "4A90D9",
        waypoints: [
            RailLine.coord(50.0833, 14.4167), // Prague
            RailLine.coord(49.1950, 16.6080), // Brno
            RailLine.coord(48.2082, 16.3738), // Vienna
        ]
    )

    // MARK: - Get route between two stations

    static func findDetailedRoute(from origin: Station, to destination: Station) -> [CLLocationCoordinate2D]? {
        // Check all lines for a path containing both stations (approximately)
        let originCoord = origin.locationCoordinate
        let destCoord = destination.locationCoordinate

        for line in allLines {
            if let segment = extractSegment(from: line.waypoints, origin: originCoord, destination: destCoord) {
                return segment
            }
        }

        return nil
    }

    private static func extractSegment(
        from waypoints: [CLLocationCoordinate2D],
        origin: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D
    ) -> [CLLocationCoordinate2D]? {
        // Find closest waypoint to origin
        guard let originIndex = findClosestWaypointIndex(to: origin, in: waypoints, threshold: 0.5) else {
            return nil
        }

        // Find closest waypoint to destination
        guard let destIndex = findClosestWaypointIndex(to: destination, in: waypoints, threshold: 0.5) else {
            return nil
        }

        // Extract segment
        let startIndex = min(originIndex, destIndex)
        let endIndex = max(originIndex, destIndex)

        var segment = Array(waypoints[startIndex...endIndex])

        // Reverse if needed
        if originIndex > destIndex {
            segment.reverse()
        }

        return segment
    }

    private static func findClosestWaypointIndex(
        to coord: CLLocationCoordinate2D,
        in waypoints: [CLLocationCoordinate2D],
        threshold: Double
    ) -> Int? {
        var closestIndex: Int?
        var closestDistance = Double.infinity

        for (index, waypoint) in waypoints.enumerated() {
            let distance = sqrt(
                pow(waypoint.latitude - coord.latitude, 2) +
                pow(waypoint.longitude - coord.longitude, 2)
            )
            if distance < closestDistance && distance < threshold {
                closestDistance = distance
                closestIndex = index
            }
        }

        return closestIndex
    }
}
