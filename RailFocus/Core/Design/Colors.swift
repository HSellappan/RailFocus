//
//  Colors.swift
//  RailFocus
//
//  Color palette for the design system
//

import SwiftUI

// MARK: - Brand Colors

extension Color {
    // Primary accent colors
    static let rfElectricBlue = Color(hex: "0066FF")
    static let rfEmerald = Color(hex: "10B981")
    static let rfCrimson = Color(hex: "DC2626")

    // Neutral palette
    static let rfBackground = Color("Background", bundle: nil)
    static let rfSurface = Color("Surface", bundle: nil)
    static let rfSurfaceElevated = Color("SurfaceElevated", bundle: nil)

    // Semantic colors
    static let rfTextPrimary = Color("TextPrimary", bundle: nil)
    static let rfTextSecondary = Color("TextSecondary", bundle: nil)
    static let rfTextTertiary = Color("TextTertiary", bundle: nil)

    // Status colors
    static let rfSuccess = Color(hex: "22C55E")
    static let rfWarning = Color(hex: "F59E0B")
    static let rfError = Color(hex: "EF4444")

    // Journey-specific colors
    static let rfTrackLine = Color(hex: "CBD5E1")
    static let rfTrackLineActive = Color(hex: "3B82F6")
    static let rfStationMarker = Color(hex: "1E293B")
}

// MARK: - Adaptive Colors (Light/Dark)

extension Color {
    /// Background color that adapts to light/dark mode
    static var rfAdaptiveBackground: Color {
        Color(light: Color(hex: "FAFAFA"), dark: Color(hex: "0A0A0A"))
    }

    /// Surface color for cards and elevated elements
    static var rfAdaptiveSurface: Color {
        Color(light: .white, dark: Color(hex: "1A1A1A"))
    }

    /// Elevated surface with subtle distinction
    static var rfAdaptiveSurfaceElevated: Color {
        Color(light: .white, dark: Color(hex: "262626"))
    }

    /// Primary text color
    static var rfAdaptiveTextPrimary: Color {
        Color(light: Color(hex: "0A0A0A"), dark: Color(hex: "FAFAFA"))
    }

    /// Secondary text color
    static var rfAdaptiveTextSecondary: Color {
        Color(light: Color(hex: "525252"), dark: Color(hex: "A3A3A3"))
    }

    /// Tertiary/muted text color
    static var rfAdaptiveTextTertiary: Color {
        Color(light: Color(hex: "A3A3A3"), dark: Color(hex: "525252"))
    }

    /// Subtle border color
    static var rfAdaptiveBorder: Color {
        Color(light: Color(hex: "E5E5E5"), dark: Color(hex: "2A2A2A"))
    }
}

// MARK: - Color Initializers

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Create a color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
