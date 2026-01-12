//
//  RideModeView.swift
//  RailFocus
//
//  Full-screen immersive focus session view with map tracking.
//  Train follows real rail routes with flight-tracker style UI.
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
    @State private var isSoundEnabled = true
    @State private var smoothProgress: Double = 0
    @State private var updateTimer: Timer?

    var body: some View {
        if let journey = appState.activeJourney {
            ZStack {
                // Full-screen satellite map
                railMapView
                    .ignoresSafeArea()

                // Overlay controls
                VStack {
                    // Top bar with controls
                    topControlsBar

                    Spacer()

                    // Bottom stats bar
                    bottomStatsBar
                }

                // Origin station label (yellow badge like ORD in screenshot)
                stationBadge
            }
            .preferredColorScheme(.dark)
            .onAppear {
                setupRailPath()
                startContinuousUpdates()
            }
            .onDisappear {
                stopContinuousUpdates()
            }
            .onChange(of: appState.timerService.state) { _, newState in
                if newState == .completed {
                    stopContinuousUpdates()
                    appState.completeJourney()
                }
            }
            .confirmationDialog(
                "End Journey Early?",
                isPresented: $showEndConfirmation,
                titleVisibility: .visible
            ) {
                Button("End Journey", role: .destructive) {
                    stopContinuousUpdates()
                    appState.interruptJourney()
                }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Your progress will be saved, but this journey will be marked as interrupted.")
            }
        } else {
            noJourneyView
        }
    }

    // MARK: - Continuous Updates

    private func startContinuousUpdates() {
        // Update train position 20 times per second for smooth movement
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateTrainPositionSmooth()
        }
    }

    private func stopContinuousUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateTrainPositionSmooth() {
        let targetProgress = appState.timerService.progress

        // Smoothly interpolate towards target progress
        let smoothingFactor = 0.15
        smoothProgress += (targetProgress - smoothProgress) * smoothingFactor

        updateTrainPosition(progress: smoothProgress)
    }

    // MARK: - No Journey View

    private var noJourneyView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.white.opacity(0.3))

                Text("No active journey")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
    }

    // MARK: - Rail Map

    private var railMapView: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            // Rail path line (thin route line like flight tracker)
            if railPath.count >= 2 {
                MapPolyline(coordinates: railPath)
                    .stroke(Color(hex: "FF3B5C").opacity(0.7), lineWidth: 2)
            }

            // Origin station marker
            if let journey = appState.activeJourney {
                // Small dot at origin
                Annotation("", coordinate: journey.originStation.locationCoordinate) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }

                // Small dot at destination
                Annotation("", coordinate: journey.destinationStation.locationCoordinate) {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                }

                // Train marker (moves along the route)
                if let position = currentPosition {
                    Annotation("", coordinate: position) {
                        HighSpeedTrainIcon(heading: trainHeading)
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
    }

    // MARK: - Station Badge (Yellow like ORD in screenshot)

    private var stationBadge: some View {
        GeometryReader { geometry in
            if let journey = appState.activeJourney, currentPosition != nil {
                // Position badge near the train but offset
                let badgePosition = CGPoint(
                    x: geometry.size.width * 0.48,
                    y: geometry.size.height * 0.58
                )

                HStack(spacing: 4) {
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 10, weight: .bold))
                    Text(journey.originStation.code)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.yellow)
                )
                .position(badgePosition)
            }
        }
    }

    // MARK: - Top Controls Bar

    private var topControlsBar: some View {
        HStack(alignment: .top) {
            // Left side controls
            VStack(spacing: 12) {
                // Pause/Play button
                Button {
                    if appState.timerService.state == .running {
                        appState.timerService.pause()
                    } else {
                        appState.timerService.resume()
                    }
                } label: {
                    Image(systemName: appState.timerService.state == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.4))
                        )
                }

                // Sound toggle button
                Button {
                    isSoundEnabled.toggle()
                } label: {
                    Image(systemName: isSoundEnabled ? "waveform" : "speaker.slash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.4))
                        )
                }
            }

            Spacer()

            // Right side controls
            VStack(spacing: 12) {
                // Compass/North indicator
                Image(systemName: "location.north.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.4))
                    )

                // Map layers button
                Button {
                    // Toggle map style if needed
                } label: {
                    Image(systemName: "square.2.layers.3d")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.4))
                        )
                }

                // End journey button
                Button {
                    showEndConfirmation = true
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.4))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
    }

    // MARK: - Bottom Stats Bar

    private var bottomStatsBar: some View {
        HStack(alignment: .bottom) {
            // Time Remaining (left side)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 10))
                    Text("Maps")
                        .font(.system(size: 11))
                }
                .foregroundStyle(Color.white.opacity(0.5))

                Text("Time Remaining")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text(formattedTimeRemaining)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Distance Remaining (right side)
            VStack(alignment: .trailing, spacing: 2) {
                Text("Distance Remaining")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text(formattedDistanceRemaining)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .padding(.bottom, 20)
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

        // Try to find detailed route from EuropeanRailNetwork
        if let detailedRoute = EuropeanRailNetwork.findDetailedRoute(from: origin, to: destination) {
            // Use the detailed waypoints and interpolate between them
            railPath = interpolateWaypoints(detailedRoute, pointsPerSegment: 20)
        } else {
            // Fallback: try TrainRoute
            if let route = TrainRoute.findRoute(from: origin, to: destination) {
                railPath = getRouteSegment(route: route, from: origin, to: destination)
            } else {
                // Final fallback: direct path with many points
                railPath = createInterpolatedPath(
                    from: origin.locationCoordinate,
                    to: destination.locationCoordinate,
                    segments: 100
                )
            }
        }

        currentPosition = railPath.first
        smoothProgress = 0
        updateCamera()
    }

    private func interpolateWaypoints(_ waypoints: [CLLocationCoordinate2D], pointsPerSegment: Int) -> [CLLocationCoordinate2D] {
        guard waypoints.count >= 2 else { return waypoints }

        var result: [CLLocationCoordinate2D] = []

        for i in 0..<waypoints.count - 1 {
            let start = waypoints[i]
            let end = waypoints[i + 1]

            for j in 0..<pointsPerSegment {
                let fraction = Double(j) / Double(pointsPerSegment)
                let lat = start.latitude + (end.latitude - start.latitude) * fraction
                let lon = start.longitude + (end.longitude - start.longitude) * fraction
                result.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }

        // Add final point
        if let last = waypoints.last {
            result.append(last)
        }

        return result
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

        // Calculate exact position with interpolation between waypoints
        let exactIndex = Double(railPath.count - 1) * progress
        let lowerIndex = Int(exactIndex)
        let upperIndex = min(lowerIndex + 1, railPath.count - 1)
        let fraction = exactIndex - Double(lowerIndex)

        let lowerCoord = railPath[lowerIndex]
        let upperCoord = railPath[upperIndex]

        // Interpolate position between waypoints for smoother movement
        let interpolatedLat = lowerCoord.latitude + (upperCoord.latitude - lowerCoord.latitude) * fraction
        let interpolatedLon = lowerCoord.longitude + (upperCoord.longitude - lowerCoord.longitude) * fraction
        let newPosition = CLLocationCoordinate2D(latitude: interpolatedLat, longitude: interpolatedLon)

        // Calculate heading towards next waypoint
        if upperIndex < railPath.count {
            trainHeading = calculateHeading(from: newPosition, to: upperCoord)
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

// MARK: - High Speed Train Icon (Bird's Eye View)

struct HighSpeedTrainIcon: View {
    let heading: Double

    var body: some View {
        ZStack {
            // Glow effect
            Ellipse()
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 20)
                .blur(radius: 6)

            // Train body (bullet train shape from above)
            BulletTrainShape()
                .fill(Color.white)
                .frame(width: 32, height: 14)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
        }
        .rotationEffect(.degrees(heading))
    }
}

// MARK: - Bullet Train Shape (Top-down view)

struct BulletTrainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Streamlined bullet train from above
        // Front nose (pointed)
        path.move(to: CGPoint(x: width, y: height / 2))

        // Top side curve from nose to body
        path.addQuadCurve(
            to: CGPoint(x: width * 0.7, y: 0),
            control: CGPoint(x: width * 0.9, y: height * 0.15)
        )

        // Top straight body
        path.addLine(to: CGPoint(x: width * 0.15, y: 0))

        // Rear curve (top)
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height / 2),
            control: CGPoint(x: 0, y: 0)
        )

        // Rear curve (bottom)
        path.addQuadCurve(
            to: CGPoint(x: width * 0.15, y: height),
            control: CGPoint(x: 0, y: height)
        )

        // Bottom straight body
        path.addLine(to: CGPoint(x: width * 0.7, y: height))

        // Bottom side curve from body to nose
        path.addQuadCurve(
            to: CGPoint(x: width, y: height / 2),
            control: CGPoint(x: width * 0.9, y: height * 0.85)
        )

        path.closeSubpath()

        return path
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
