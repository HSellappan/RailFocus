//
//  RideModeView.swift
//  RailFocus
//
//  Full-screen map view showing train journey progress (flight tracker style)
//

import SwiftUI
import MapKit

struct RideModeView: View {
    @Environment(\.appState) private var appState
    @State private var showEndConfirmation = false
    @State private var railPath: [CLLocationCoordinate2D] = []
    @State private var currentPosition: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var trainHeading: Double = 0

    var body: some View {
        ZStack {
            // Full-screen satellite map
            railMapView
                .ignoresSafeArea()

            // Overlay controls
            VStack {
                // Top bar with pause button
                topBar

                Spacer()

                // Bottom stats bar
                bottomStatsBar
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupRailPath()
        }
        .onChange(of: appState.timerService.progress) { _, newValue in
            updateTrainPosition(progress: newValue)
        }
        .onChange(of: appState.timerService.state) { _, newState in
            if newState == .completed {
                appState.completeJourney()
            }
        }
        .confirmationDialog(
            "End Journey Early?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Journey", role: .destructive) {
                appState.interruptJourney()
            }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Your progress will be saved, but this journey will be marked as interrupted.")
        }
    }

    // MARK: - Rail Map

    private var railMapView: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            // Rail path line (the actual route)
            if railPath.count >= 2 {
                MapPolyline(coordinates: railPath)
                    .stroke(Color.white.opacity(0.6), lineWidth: 3)
            }

            // Origin station marker
            if let journey = appState.activeJourney {
                Annotation("", coordinate: journey.originStation.locationCoordinate) {
                    StationDot(isOrigin: true)
                }

                // Destination station marker
                Annotation("", coordinate: journey.destinationStation.locationCoordinate) {
                    StationDot(isOrigin: false)
                }

                // Train marker (moves along the route)
                if let position = currentPosition {
                    Annotation("", coordinate: position) {
                        TrainMarkerView(heading: trainHeading)
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Pause/Play button
            Button {
                if appState.timerService.state == .running {
                    appState.timerService.pause()
                } else {
                    appState.timerService.resume()
                }
            } label: {
                Image(systemName: appState.timerService.state == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                    )
            }

            Spacer()

            // Right side controls
            VStack(spacing: 12) {
                // End journey button
                Button {
                    showEndConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                }

                // Status indicator
                if let journey = appState.activeJourney {
                    VStack(spacing: 4) {
                        Image(systemName: "train.side.front.car")
                            .font(.system(size: 14))
                        Text(journey.originStation.railLine)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.5))
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
    }

    // MARK: - Bottom Stats Bar

    private var bottomStatsBar: some View {
        HStack {
            // Time Remaining
            VStack(alignment: .leading, spacing: 4) {
                Text("Time Remaining")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text(formattedTimeRemaining)
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Distance Remaining
            VStack(alignment: .trailing, spacing: 4) {
                Text("Distance Remaining")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text(formattedDistanceRemaining)
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Formatted Values

    private var formattedTimeRemaining: String {
        let remaining = appState.timerService.timeRemaining
        let minutes = Int(remaining) / 60
        return "\(minutes) min"
    }

    private var formattedDistanceRemaining: String {
        guard let journey = appState.activeJourney else { return "0 mi" }
        let remainingKm = journey.distanceKm * (1 - appState.timerService.progress)
        let remainingMiles = remainingKm * 0.621371
        return String(format: "%.0f mi", remainingMiles)
    }

    // MARK: - Rail Path Setup

    private func setupRailPath() {
        guard let journey = appState.activeJourney else { return }

        let origin = journey.originStation
        let destination = journey.destinationStation

        // Try to find the actual rail route
        if let route = TrainRoute.findRoute(from: origin, to: destination) {
            // Get waypoints between origin and destination on this route
            railPath = getRouteSegment(route: route, from: origin, to: destination)
        } else {
            // Fallback: create interpolated path along great circle
            railPath = createInterpolatedPath(
                from: origin.locationCoordinate,
                to: destination.locationCoordinate,
                segments: 100
            )
        }

        currentPosition = railPath.first
        updateCamera()
    }

    private func getRouteSegment(route: TrainRoute, from origin: Station, to destination: Station) -> [CLLocationCoordinate2D] {
        guard let originIndex = route.stations.firstIndex(of: origin),
              let destIndex = route.stations.firstIndex(of: destination) else {
            return createInterpolatedPath(
                from: origin.locationCoordinate,
                to: destination.locationCoordinate,
                segments: 100
            )
        }

        let startIndex = min(originIndex, destIndex)
        let endIndex = max(originIndex, destIndex)
        let stationSegment = Array(route.stations[startIndex...endIndex])

        // If traveling in reverse, reverse the segment
        let orderedStations = originIndex < destIndex ? stationSegment : stationSegment.reversed()

        // Create detailed path with interpolation between each station pair
        var detailedPath: [CLLocationCoordinate2D] = []
        for i in 0..<orderedStations.count - 1 {
            let from = orderedStations[i].locationCoordinate
            let to = orderedStations[i + 1].locationCoordinate
            let segment = createInterpolatedPath(from: from, to: to, segments: 30)
            if i == 0 {
                detailedPath.append(contentsOf: segment)
            } else {
                detailedPath.append(contentsOf: segment.dropFirst())
            }
        }

        return detailedPath
    }

    private func createInterpolatedPath(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        segments: Int
    ) -> [CLLocationCoordinate2D] {
        var path: [CLLocationCoordinate2D] = []

        for i in 0...segments {
            let fraction = Double(i) / Double(segments)
            let lat = start.latitude + (end.latitude - start.latitude) * fraction
            let lon = start.longitude + (end.longitude - start.longitude) * fraction
            path.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        return path
    }

    private func updateCamera() {
        guard let journey = appState.activeJourney else { return }

        let origin = journey.originStation.locationCoordinate
        let destination = journey.destinationStation.locationCoordinate

        let centerLat = (origin.latitude + destination.latitude) / 2
        let centerLon = (origin.longitude + destination.longitude) / 2

        // Calculate distance to set appropriate zoom
        let latDiff = abs(origin.latitude - destination.latitude)
        let lonDiff = abs(origin.longitude - destination.longitude)
        let maxDiff = max(latDiff, lonDiff)

        // Adjust camera distance based on route length
        let distance = max(maxDiff * 200000, 500000)

        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                distance: distance,
                heading: 0,
                pitch: 0
            )
        )
    }

    private func updateTrainPosition(progress: Double) {
        guard railPath.count > 1 else { return }

        let index = Int(Double(railPath.count - 1) * progress)
        let clampedIndex = min(max(index, 0), railPath.count - 1)
        let newPosition = railPath[clampedIndex]

        // Calculate heading towards next waypoint
        if clampedIndex < railPath.count - 1 {
            let nextIndex = clampedIndex + 1
            let next = railPath[nextIndex]
            trainHeading = calculateHeading(from: newPosition, to: next)
        }

        currentPosition = newPosition
    }

    private func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let deltaLon = to.longitude - from.longitude
        let deltaLat = to.latitude - from.latitude

        let angle = atan2(deltaLon, deltaLat) * 180 / .pi
        return angle
    }
}

// MARK: - Train Marker View

struct TrainMarkerView: View {
    let heading: Double

    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 50, height: 50)
                .blur(radius: 8)

            // Train icon (pointing in direction of travel)
            Image(systemName: "train.side.front.car")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                .rotationEffect(.degrees(heading - 90)) // Adjust for icon orientation
        }
    }
}

// MARK: - Station Dot

struct StationDot: View {
    let isOrigin: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isOrigin ? Color.white : Color.white.opacity(0.3))
                .frame(width: 16, height: 16)

            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 16, height: 16)
        }
    }
}

// MARK: - Preview

#Preview {
    RideModeView()
        .environment(\.appState, {
            let state = AppState()
            state.activeJourney = Journey(
                origin: .parisGareDeLyon,
                destination: .lyonPartDieu,
                duration: 1500
            )
            return state
        }())
}
