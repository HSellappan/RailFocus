//
//  UserSettings.swift
//  RailFocus
//
//  User preferences and settings
//

import Foundation
import SwiftUI

// MARK: - Map Style

enum RFMapStyle: String, Codable, CaseIterable, Identifiable {
    case monochrome
    case terra
    case standard
    case satellite

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var description: String {
        switch self {
        case .monochrome: return "Dark minimal style"
        case .terra: return "Earth tones"
        case .standard: return "Classic map view"
        case .satellite: return "Satellite imagery"
        }
    }
}

// MARK: - User Settings

@Observable
final class UserSettings {
    // MARK: - Keys
    private enum Keys {
        static let mapStyle = "mapStyle"
        static let showLabels = "showLabels"
        static let defaultDuration = "defaultDuration"
        static let ambientSounds = "ambientSounds"
        static let hapticFeedback = "hapticFeedback"
        static let notificationsEnabled = "notificationsEnabled"
        static let userCity = "userCity"
        static let userLatitude = "userLatitude"
        static let userLongitude = "userLongitude"
    }

    // MARK: - Properties

    var mapStyle: RFMapStyle {
        didSet { save() }
    }

    var showLabels: Bool {
        didSet { save() }
    }

    var defaultDuration: Int {
        didSet { save() }
    }

    var ambientSoundsEnabled: Bool {
        didSet { save() }
    }

    var hapticFeedbackEnabled: Bool {
        didSet { save() }
    }

    var notificationsEnabled: Bool {
        didSet { save() }
    }

    var userCity: String {
        didSet { save() }
    }

    var userLatitude: Double {
        didSet { save() }
    }

    var userLongitude: Double {
        didSet { save() }
    }

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard

        if let styleRaw = defaults.string(forKey: Keys.mapStyle),
           let style = RFMapStyle(rawValue: styleRaw) {
            self.mapStyle = style
        } else {
            self.mapStyle = .satellite
        }

        self.showLabels = defaults.object(forKey: Keys.showLabels) as? Bool ?? false
        self.defaultDuration = defaults.object(forKey: Keys.defaultDuration) as? Int ?? 25
        self.ambientSoundsEnabled = defaults.object(forKey: Keys.ambientSounds) as? Bool ?? true
        self.hapticFeedbackEnabled = defaults.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.userCity = defaults.string(forKey: Keys.userCity) ?? "Chicago"
        self.userLatitude = defaults.double(forKey: Keys.userLatitude)
        self.userLongitude = defaults.double(forKey: Keys.userLongitude)

        // Default to Chicago if no location set
        if userLatitude == 0 && userLongitude == 0 {
            userLatitude = 41.8781
            userLongitude = -87.6298
        }
    }

    // MARK: - Save

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(mapStyle.rawValue, forKey: Keys.mapStyle)
        defaults.set(showLabels, forKey: Keys.showLabels)
        defaults.set(defaultDuration, forKey: Keys.defaultDuration)
        defaults.set(ambientSoundsEnabled, forKey: Keys.ambientSounds)
        defaults.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedback)
        defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        defaults.set(userCity, forKey: Keys.userCity)
        defaults.set(userLatitude, forKey: Keys.userLatitude)
        defaults.set(userLongitude, forKey: Keys.userLongitude)
    }

    // MARK: - Computed

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning!"
        case 12..<17: return "Good afternoon!"
        case 17..<21: return "Good evening!"
        default: return "Good night!"
        }
    }
}
