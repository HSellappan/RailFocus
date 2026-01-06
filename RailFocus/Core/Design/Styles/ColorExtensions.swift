//
//  ColorExtensions.swift
//  RailFocus
//
//  Created by Harold S on 1/6/26.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    /// Success color for RailFocus app
    static var rfSuccess: Color {
        Color(red: 0.2, green: 0.7, blue: 0.3) // A pleasant green color
    }

    /// Primary color for RailFocus app
    static var rfPrimary: Color {
        Color(red: 0.2, green: 0.4, blue: 0.8) // A pleasant blue color
    }

    /// Error color for RailFocus app
    static var rfError: Color {
        Color(red: 0.8, green: 0.2, blue: 0.2) // A red color
    }

    /// Warning color for RailFocus app
    static var rfWarning: Color {
        Color(red: 0.9, green: 0.6, blue: 0.1) // An orange color
    }
}
