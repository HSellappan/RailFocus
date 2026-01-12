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
    // Detailed waypoints following the actual LGV Sud-Est high-speed rail corridor

    static let tgvSudEst = RailLine(
        name: "TGV Sud-Est",
        color: "4A90D9",
        waypoints: [
            // Paris Gare de Lyon
            RailLine.coord(48.8443, 2.3743),
            // Leaving Paris - Villeneuve-Saint-Georges
            RailLine.coord(48.7331, 2.4486),
            // Lieusaint area
            RailLine.coord(48.6308, 2.5472),
            // Melun area
            RailLine.coord(48.5400, 2.6600),
            // Near Montereau
            RailLine.coord(48.3833, 2.9500),
            // Near Sens
            RailLine.coord(48.1972, 3.2833),
            // Near Joigny
            RailLine.coord(47.9833, 3.4000),
            // Near Auxerre (LGV passes east)
            RailLine.coord(47.7500, 3.6500),
            // Near Tonnerre
            RailLine.coord(47.8550, 3.9750),
            // Near Montbard
            RailLine.coord(47.6250, 4.3375),
            // LGV bypasses Dijon to the east
            RailLine.coord(47.3500, 5.1500),
            // Near Beaune
            RailLine.coord(47.0250, 4.8400),
            // Near Chalon-sur-Saône
            RailLine.coord(46.7833, 4.8500),
            // Mâcon-Loché TGV station
            RailLine.coord(46.2917, 4.7917),
            // Approaching Lyon
            RailLine.coord(45.9000, 4.8200),
            // Lyon Part-Dieu
            RailLine.coord(45.7606, 4.8594),
            // Lyon to Valence - Vienne
            RailLine.coord(45.5250, 4.8750),
            // Near Tain-l'Hermitage
            RailLine.coord(45.0667, 4.8500),
            // Valence TGV
            RailLine.coord(44.9250, 4.9000),
            // Near Montélimar
            RailLine.coord(44.5580, 4.7500),
            // Near Orange
            RailLine.coord(44.1380, 4.8100),
            // Avignon TGV
            RailLine.coord(43.9220, 4.7860),
            // Near Nîmes
            RailLine.coord(43.8330, 4.3600),
            // Approaching Marseille
            RailLine.coord(43.4500, 5.2000),
            // Marseille Saint-Charles
            RailLine.coord(43.3028, 5.3803),
            // Near Aubagne
            RailLine.coord(43.2950, 5.5700),
            // Toulon
            RailLine.coord(43.1230, 5.9280),
            // Near Hyères
            RailLine.coord(43.1200, 6.1300),
            // Near Fréjus
            RailLine.coord(43.4330, 6.7370),
            // Cannes
            RailLine.coord(43.5510, 7.0128),
            // Antibes
            RailLine.coord(43.5808, 7.1239),
            // Nice-Ville
            RailLine.coord(43.7044, 7.2619),
        ]
    )

    // MARK: - TGV Atlantique (Paris - Bordeaux)
    // Detailed waypoints following the LGV Atlantique and LGV Sud Europe Atlantique

    static let tgvAtlantique = RailLine(
        name: "TGV Atlantique",
        color: "4A90D9",
        waypoints: [
            // Paris Montparnasse
            RailLine.coord(48.8414, 2.3187),
            // Massy TGV
            RailLine.coord(48.7253, 2.2608),
            // Near Artenay
            RailLine.coord(48.0833, 1.8833),
            // Near Vendôme
            RailLine.coord(47.7928, 1.0656),
            // Near Tours (Saint-Pierre-des-Corps)
            RailLine.coord(47.3856, 0.7250),
            // Tours junction
            RailLine.coord(47.3900, 0.6900),
            // Near Châtellerault
            RailLine.coord(46.8167, 0.5500),
            // Poitiers (Futuroscope TGV)
            RailLine.coord(46.6667, 0.3667),
            // Near Ruffec
            RailLine.coord(46.0250, 0.1917),
            // Angoulême
            RailLine.coord(45.6500, 0.1600),
            // Near Coutras
            RailLine.coord(45.0400, -0.1300),
            // Near Libourne
            RailLine.coord(44.9167, -0.2333),
            // Bordeaux Saint-Jean
            RailLine.coord(44.8256, -0.5567),
        ]
    )

    // MARK: - TGV Est (Paris - Strasbourg)
    // Detailed waypoints following the LGV Est européenne

    static let tgvEst = RailLine(
        name: "TGV Est",
        color: "4A90D9",
        waypoints: [
            // Paris Est
            RailLine.coord(48.8767, 2.3590),
            // Near Vaires-sur-Marne
            RailLine.coord(48.8700, 2.6500),
            // Near Meaux area
            RailLine.coord(48.9600, 2.9000),
            // Near Château-Thierry
            RailLine.coord(49.0500, 3.4000),
            // Champagne-Ardenne TGV
            RailLine.coord(49.1167, 4.0167),
            // Near Châlons-en-Champagne
            RailLine.coord(48.9600, 4.3600),
            // Near Vitry-le-François
            RailLine.coord(48.7250, 4.5850),
            // Near Bar-le-Duc
            RailLine.coord(48.7750, 5.1600),
            // Meuse TGV
            RailLine.coord(48.9000, 5.3833),
            // Lorraine TGV
            RailLine.coord(48.9500, 6.1700),
            // Near Nancy
            RailLine.coord(48.6900, 6.1700),
            // Near Sarrebourg
            RailLine.coord(48.7350, 7.0550),
            // Near Saverne
            RailLine.coord(48.7400, 7.3600),
            // Strasbourg
            RailLine.coord(48.5850, 7.7350),
        ]
    )

    // MARK: - ICE North-South (Hamburg - Frankfurt)
    // Detailed waypoints following the Hannover-Würzburg high-speed line

    static let iceNorthSouth = RailLine(
        name: "ICE North-South",
        color: "4A90D9",
        waypoints: [
            // Hamburg Hbf
            RailLine.coord(53.5530, 10.0069),
            // Hamburg-Harburg
            RailLine.coord(53.4560, 9.9920),
            // Near Lüneburg
            RailLine.coord(53.2500, 10.4000),
            // Near Uelzen
            RailLine.coord(52.9650, 10.5580),
            // Near Celle
            RailLine.coord(52.6250, 10.0800),
            // Hannover Hbf
            RailLine.coord(52.3770, 9.7420),
            // Near Alfeld
            RailLine.coord(51.9850, 9.8250),
            // Göttingen
            RailLine.coord(51.5360, 9.9260),
            // Near Nörten-Hardenberg
            RailLine.coord(51.6250, 9.9350),
            // Near Northeim
            RailLine.coord(51.7050, 9.9990),
            // Kassel-Wilhelmshöhe
            RailLine.coord(51.3130, 9.4470),
            // Near Bad Hersfeld
            RailLine.coord(50.8680, 9.7080),
            // Fulda
            RailLine.coord(50.5540, 9.6840),
            // Near Schlüchtern
            RailLine.coord(50.3490, 9.5250),
            // Near Hanau
            RailLine.coord(50.1330, 8.9170),
            // Frankfurt Hbf
            RailLine.coord(50.1072, 8.6638),
        ]
    )

    // MARK: - ICE East-West (Cologne - Berlin)
    // Detailed waypoints following the Köln-Berlin high-speed line

    static let iceEastWest = RailLine(
        name: "ICE East-West",
        color: "4A90D9",
        waypoints: [
            // Cologne Hbf
            RailLine.coord(50.9430, 6.9589),
            // Cologne-Deutz
            RailLine.coord(50.9370, 6.9750),
            // Near Leverkusen
            RailLine.coord(51.0330, 6.9880),
            // Düsseldorf Hbf
            RailLine.coord(51.2200, 6.7940),
            // Duisburg Hbf
            RailLine.coord(51.4300, 6.7760),
            // Essen Hbf
            RailLine.coord(51.4510, 7.0140),
            // Bochum Hbf
            RailLine.coord(51.4780, 7.2230),
            // Dortmund Hbf
            RailLine.coord(51.5180, 7.4590),
            // Near Hamm
            RailLine.coord(51.6780, 7.8070),
            // Near Bielefeld
            RailLine.coord(52.0290, 8.5320),
            // Hannover Hbf
            RailLine.coord(52.3770, 9.7420),
            // Near Braunschweig
            RailLine.coord(52.2530, 10.5400),
            // Wolfsburg Hbf
            RailLine.coord(52.4300, 10.7880),
            // Near Stendal
            RailLine.coord(52.6060, 11.8590),
            // Berlin Spandau
            RailLine.coord(52.5340, 13.1980),
            // Berlin Hbf
            RailLine.coord(52.5250, 13.3694),
        ]
    )

    // MARK: - ICE Berlin-Munich
    // Detailed waypoints following the VDE 8 high-speed line

    static let iceBerlinMunich = RailLine(
        name: "ICE Berlin-Munich",
        color: "4A90D9",
        waypoints: [
            // Berlin Hbf
            RailLine.coord(52.5250, 13.3694),
            // Berlin Südkreuz
            RailLine.coord(52.4756, 13.3653),
            // Near Jüterbog
            RailLine.coord(51.9920, 13.0730),
            // Near Lutherstadt Wittenberg
            RailLine.coord(51.8670, 12.6490),
            // Halle (Saale) Hbf
            RailLine.coord(51.4770, 11.9870),
            // Near Merseburg
            RailLine.coord(51.3540, 11.9930),
            // Leipzig Hbf
            RailLine.coord(51.3450, 12.3820),
            // Near Altenburg
            RailLine.coord(50.9870, 12.4360),
            // Near Zwickau
            RailLine.coord(50.7180, 12.4960),
            // Near Plauen
            RailLine.coord(50.4960, 12.1340),
            // Near Hof
            RailLine.coord(50.3030, 11.9140),
            // Near Bayreuth
            RailLine.coord(49.9480, 11.5780),
            // Nuremberg Hbf
            RailLine.coord(49.4460, 11.0820),
            // Near Allersberg
            RailLine.coord(49.2510, 11.2360),
            // Ingolstadt Hbf
            RailLine.coord(48.8230, 11.4510),
            // Near Petershausen
            RailLine.coord(48.4060, 11.4720),
            // Munich Hbf
            RailLine.coord(48.1403, 11.5600),
        ]
    )

    // MARK: - ICE Rhine-Main (Frankfurt - Cologne)
    // Detailed waypoints following the Rhine corridor

    static let iceRhineMain = RailLine(
        name: "ICE Rhine-Main",
        color: "4A90D9",
        waypoints: [
            // Frankfurt Hbf
            RailLine.coord(50.1072, 8.6638),
            // Frankfurt Flughafen
            RailLine.coord(50.0520, 8.5700),
            // Mainz Hbf
            RailLine.coord(50.0012, 8.2590),
            // Near Bingen
            RailLine.coord(49.9680, 7.8990),
            // Near Bacharach
            RailLine.coord(50.0570, 7.7710),
            // Near St. Goar
            RailLine.coord(50.1540, 7.7120),
            // Koblenz Hbf
            RailLine.coord(50.3530, 7.5980),
            // Near Andernach
            RailLine.coord(50.4390, 7.4040),
            // Near Remagen
            RailLine.coord(50.5740, 7.2290),
            // Bonn Hbf
            RailLine.coord(50.7320, 7.0970),
            // Cologne Hbf
            RailLine.coord(50.9430, 6.9589),
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
    // Detailed waypoints following the Direttissima and TAV lines

    static let frecciarossaNorthSouth = RailLine(
        name: "Frecciarossa",
        color: "4A90D9",
        waypoints: [
            // Milano Centrale
            RailLine.coord(45.4860, 9.2040),
            // Near Lodi
            RailLine.coord(45.3140, 9.5030),
            // Near Piacenza
            RailLine.coord(45.0520, 9.6930),
            // Near Parma
            RailLine.coord(44.8010, 10.3290),
            // Near Reggio Emilia
            RailLine.coord(44.6980, 10.6310),
            // Near Modena
            RailLine.coord(44.6460, 10.9250),
            // Bologna Centrale
            RailLine.coord(44.5060, 11.3430),
            // Near Prato
            RailLine.coord(43.8810, 11.0970),
            // Firenze Santa Maria Novella
            RailLine.coord(43.7760, 11.2480),
            // Near Arezzo
            RailLine.coord(43.4630, 11.8820),
            // Near Chiusi
            RailLine.coord(43.0170, 11.9480),
            // Near Orvieto
            RailLine.coord(42.7190, 12.1130),
            // Near Orte
            RailLine.coord(42.4600, 12.4560),
            // Roma Termini
            RailLine.coord(41.9010, 12.5020),
            // Roma Tiburtina
            RailLine.coord(41.9100, 12.5310),
            // Near Frosinone
            RailLine.coord(41.6400, 13.3500),
            // Near Caserta
            RailLine.coord(41.0750, 14.3330),
            // Napoli Centrale
            RailLine.coord(40.8530, 14.2720),
        ]
    )

    // MARK: - Frecciarossa Milan-Venice
    // Detailed waypoints following the Milan-Venice line

    static let frecciarossaMilanVenice = RailLine(
        name: "Frecciarossa Venice",
        color: "4A90D9",
        waypoints: [
            // Milano Centrale
            RailLine.coord(45.4860, 9.2040),
            // Near Treviglio
            RailLine.coord(45.5210, 9.5940),
            // Brescia
            RailLine.coord(45.5310, 10.2130),
            // Near Desenzano
            RailLine.coord(45.4690, 10.5400),
            // Near Peschiera
            RailLine.coord(45.4400, 10.6910),
            // Verona Porta Nuova
            RailLine.coord(45.4290, 10.9820),
            // Near Vicenza
            RailLine.coord(45.5460, 11.5350),
            // Padova
            RailLine.coord(45.4180, 11.8800),
            // Near Mestre
            RailLine.coord(45.4820, 12.2380),
            // Venezia Santa Lucia
            RailLine.coord(45.4410, 12.3210),
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
