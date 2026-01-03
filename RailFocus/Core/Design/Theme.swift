//
//  Theme.swift
//  RailFocus
//
//  Design system theme configuration
//

import SwiftUI

// MARK: - Theme

@Observable
final class Theme {
    static let shared = Theme()

    var accentStyle: AccentStyle = .electricBlue

    private init() {}
}

// MARK: - Accent Styles

enum AccentStyle: String, CaseIterable, Identifiable {
    case electricBlue
    case emerald
    case crimson

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .electricBlue: return .rfElectricBlue
        case .emerald: return .rfEmerald
        case .crimson: return .rfCrimson
        }
    }

    var displayName: String {
        switch self {
        case .electricBlue: return "Electric Blue"
        case .emerald: return "Emerald"
        case .crimson: return "Crimson"
        }
    }
}

// MARK: - Theme Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.shared
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
