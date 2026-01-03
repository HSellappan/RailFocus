//
//  Typography.swift
//  RailFocus
//
//  Typography system using SF Pro
//

import SwiftUI

// MARK: - Typography Scale

enum RFTypography {
    /// Large title - 34pt, bold
    case largeTitle
    /// Title 1 - 28pt, bold
    case title1
    /// Title 2 - 22pt, bold
    case title2
    /// Title 3 - 20pt, semibold
    case title3
    /// Headline - 17pt, semibold
    case headline
    /// Body - 17pt, regular
    case body
    /// Body semibold - 17pt, semibold
    case bodySemibold
    /// Callout - 16pt, regular
    case callout
    /// Subheadline - 15pt, regular
    case subheadline
    /// Footnote - 13pt, regular
    case footnote
    /// Caption 1 - 12pt, regular
    case caption1
    /// Caption 2 - 11pt, regular
    case caption2

    var font: Font {
        switch self {
        case .largeTitle:
            return .system(size: 34, weight: .bold, design: .default)
        case .title1:
            return .system(size: 28, weight: .bold, design: .default)
        case .title2:
            return .system(size: 22, weight: .bold, design: .default)
        case .title3:
            return .system(size: 20, weight: .semibold, design: .default)
        case .headline:
            return .system(size: 17, weight: .semibold, design: .default)
        case .body:
            return .system(size: 17, weight: .regular, design: .default)
        case .bodySemibold:
            return .system(size: 17, weight: .semibold, design: .default)
        case .callout:
            return .system(size: 16, weight: .regular, design: .default)
        case .subheadline:
            return .system(size: 15, weight: .regular, design: .default)
        case .footnote:
            return .system(size: 13, weight: .regular, design: .default)
        case .caption1:
            return .system(size: 12, weight: .regular, design: .default)
        case .caption2:
            return .system(size: 11, weight: .regular, design: .default)
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .largeTitle: return 41
        case .title1: return 34
        case .title2: return 28
        case .title3: return 25
        case .headline: return 22
        case .body: return 22
        case .bodySemibold: return 22
        case .callout: return 21
        case .subheadline: return 20
        case .footnote: return 18
        case .caption1: return 16
        case .caption2: return 13
        }
    }
}

// MARK: - View Modifier

struct RFTypographyModifier: ViewModifier {
    let typography: RFTypography

    func body(content: Content) -> some View {
        content
            .font(typography.font)
            .lineSpacing(typography.lineHeight - typography.font.pointSize)
    }
}

extension View {
    /// Apply RailFocus typography style
    func rfTypography(_ style: RFTypography) -> some View {
        modifier(RFTypographyModifier(typography: style))
    }
}

// MARK: - Font Extension for Point Size

private extension Font {
    var pointSize: CGFloat {
        // Approximate point sizes for system fonts
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        default: return 17
        }
    }
}
