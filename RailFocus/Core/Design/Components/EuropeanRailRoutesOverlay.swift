//
//  EuropeanRailRoutesOverlay.swift
//  RailFocus
//
//  Reusable MapKit overlay showing all European high-speed rail routes.
//  Add this to any Map content builder to display the rail network.
//

import SwiftUI
import MapKit

// MARK: - Rail Routes Map Content

/// A collection of MapPolylines representing all European high-speed rail routes.
/// Use inside a Map's content builder.
struct EuropeanRailRoutesContent: MapContent {
    var routeColor: Color = Color(hex: "4A90D9")
    var routeOpacity: Double = 0.6
    var lineWidth: CGFloat = 2
    var showStationDots: Bool = false

    var body: some MapContent {
        // Draw all European rail lines
        ForEach(EuropeanRailNetwork.allLines) { line in
            MapPolyline(coordinates: line.waypoints)
                .stroke(routeColor.opacity(routeOpacity), lineWidth: lineWidth)
        }

        // Optionally show station markers
        if showStationDots {
            ForEach(Station.europeStations) { station in
                Annotation("", coordinate: station.locationCoordinate) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

// MARK: - Convenience Presets

extension EuropeanRailRoutesContent {
    /// Standard blue routes for home/overview maps
    static var standard: EuropeanRailRoutesContent {
        EuropeanRailRoutesContent(
            routeColor: Color(hex: "4A90D9"),
            routeOpacity: 0.6,
            lineWidth: 2,
            showStationDots: false
        )
    }

    /// Subtle routes for destination picker (less prominent)
    static var subtle: EuropeanRailRoutesContent {
        EuropeanRailRoutesContent(
            routeColor: Color(hex: "4A90D9"),
            routeOpacity: 0.3,
            lineWidth: 1.5,
            showStationDots: false
        )
    }

    /// Prominent routes for journey tracking
    static var prominent: EuropeanRailRoutesContent {
        EuropeanRailRoutesContent(
            routeColor: Color(hex: "4A90D9"),
            routeOpacity: 0.5,
            lineWidth: 2,
            showStationDots: false
        )
    }

    /// White routes for dark/satellite map backgrounds
    static var whiteLine: EuropeanRailRoutesContent {
        EuropeanRailRoutesContent(
            routeColor: .white,
            routeOpacity: 0.25,
            lineWidth: 1.5,
            showStationDots: false
        )
    }
}

// MARK: - Station Markers for Maps

struct RailStationMarker: View {
    let station: Station
    var size: CGFloat = 8
    var showLabel: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: size, height: size)

                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: size + 4, height: size + 4)
            }

            if showLabel {
                Text(station.code)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Map {
        EuropeanRailRoutesContent.standard
    }
    .mapStyle(.imagery(elevation: .realistic))
}
