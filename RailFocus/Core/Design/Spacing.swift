//
//  Spacing.swift
//  RailFocus
//
//  8pt spacing system
//

import SwiftUI

// MARK: - Spacing Constants

enum RFSpacing {
    /// 4pt - Extra small spacing
    static let xxs: CGFloat = 4
    /// 8pt - Extra small spacing
    static let xs: CGFloat = 8
    /// 12pt - Small spacing
    static let sm: CGFloat = 12
    /// 16pt - Medium spacing (default)
    static let md: CGFloat = 16
    /// 20pt - Medium-large spacing
    static let lg: CGFloat = 20
    /// 24pt - Large spacing
    static let xl: CGFloat = 24
    /// 32pt - Extra large spacing
    static let xxl: CGFloat = 32
    /// 40pt - 2X extra large spacing
    static let xxxl: CGFloat = 40
    /// 48pt - 3X extra large spacing
    static let xxxxl: CGFloat = 48
}

// MARK: - Corner Radius

enum RFCornerRadius {
    /// 8pt - Small radius
    static let small: CGFloat = 8
    /// 12pt - Medium radius
    static let medium: CGFloat = 12
    /// 14pt - Standard radius
    static let standard: CGFloat = 14
    /// 18pt - Large radius
    static let large: CGFloat = 18
    /// 24pt - Extra large radius
    static let xl: CGFloat = 24
    /// Full rounded (pill shape)
    static let full: CGFloat = 9999
}

// MARK: - Component Sizes

enum RFSize {
    /// Primary button height - 54pt
    static let buttonHeight: CGFloat = 54
    /// Secondary button height - 44pt
    static let buttonHeightSecondary: CGFloat = 44
    /// Minimum tap target - 44pt
    static let minTapTarget: CGFloat = 44
    /// Icon size small - 20pt
    static let iconSmall: CGFloat = 20
    /// Icon size medium - 24pt
    static let iconMedium: CGFloat = 24
    /// Icon size large - 28pt
    static let iconLarge: CGFloat = 28
    /// Icon size XL - 32pt
    static let iconXL: CGFloat = 32
    /// Pill/chip height - 32pt
    static let pillHeight: CGFloat = 32
    /// Card minimum height - 80pt
    static let cardMinHeight: CGFloat = 80
}

// MARK: - Shadow Styles

enum RFShadow {
    case none
    case subtle
    case medium
    case elevated

    var color: Color {
        switch self {
        case .none: return .clear
        case .subtle: return .black.opacity(0.04)
        case .medium: return .black.opacity(0.08)
        case .elevated: return .black.opacity(0.12)
        }
    }

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 4
        case .medium: return 8
        case .elevated: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 2
        case .medium: return 4
        case .elevated: return 8
        }
    }
}

// MARK: - Shadow View Modifier

struct RFShadowModifier: ViewModifier {
    let style: RFShadow

    func body(content: Content) -> some View {
        content
            .shadow(color: style.color, radius: style.radius, x: 0, y: style.y)
    }
}

extension View {
    /// Apply RailFocus shadow style
    func rfShadow(_ style: RFShadow) -> some View {
        modifier(RFShadowModifier(style: style))
    }
}

// MARK: - Animation Constants

enum RFAnimation {
    /// Quick animation - 200ms
    static let quick: Animation = .easeInOut(duration: 0.2)
    /// Standard animation - 300ms
    static let standard: Animation = .easeInOut(duration: 0.3)
    /// Slow animation - 350ms
    static let slow: Animation = .easeInOut(duration: 0.35)
    /// Spring animation for interactive elements
    static let spring: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    /// Smooth spring for larger movements
    static let smoothSpring: Animation = .spring(response: 0.5, dampingFraction: 0.8)
}
