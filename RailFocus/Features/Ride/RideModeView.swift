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
    @State private var displayLink: CADisplayLink?
    @State private var animatedProgress: Double = 0

    var body: some View {
        if let journey = appState.activeJourney {
            ZStack {
                // Full-screen map (standard style like flight tracker)
                railMapView
                    .ignoresSafeArea()

                // Left side controls
                leftControlsOverlay

                // Right side controls
                rightControlsOverlay

                // Station badge (yellow like ORD in screenshot)
                stationBadge

                // Bottom stats bar
                VStack {
                    Spacer()
                    bottomStatsBar
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                setupRailPath()
                startDisplayLink()
            }
            .onDisappear {
                stopDisplayLink()
            }
            .onChange(of: appState.timerService.state) { _, newState in
                if newState == .completed {
                    stopDisplayLink()
                    appState.completeJourney()
                }
            }
            .confirmationDialog(
                "End Journey Early?",
                isPresented: $showEndConfirmation,
                titleVisibility: .visible
            ) {
                Button("End Journey", role: .destructive) {
                    stopDisplayLink()
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

    // MARK: - Display Link for 60fps Updates

    private func startDisplayLink() {
        let link = CADisplayLink(target: DisplayLinkTarget { [self] in
            self.updateFrame()
        }, selector: #selector(DisplayLinkTarget.update))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func updateFrame() {
        let targetProgress = appState.timerService.progress

        // Smooth exponential interpolation for fluid movement
        let smoothingSpeed = 0.08
        animatedProgress += (targetProgress - animatedProgress) * smoothingSpeed

        // Clamp to prevent overshooting
        animatedProgress = min(max(animatedProgress, 0), 1)

        updateTrainPosition(progress: animatedProgress)
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

    // MARK: - Rail Map (Clean - only active route visible)

    private var railMapView: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            // ONLY the active journey rail path - thin line like flight tracker
            if railPath.count >= 2 {
                MapPolyline(coordinates: railPath)
                    .stroke(Color(hex: "E84855").opacity(0.6), lineWidth: 2)
            }

            // Train marker (moves along the route)
            if let position = currentPosition {
                Annotation("", coordinate: position) {
                    ModernTrainMapIcon(heading: trainHeading)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .including([]), showsTraffic: false))
    }

    // MARK: - Station Badge (Yellow like ORD in screenshot)

    private var stationBadge: some View {
        GeometryReader { geometry in
            if let journey = appState.activeJourney, currentPosition != nil {
                // Position badge below and slightly left of center (near train)
                HStack(spacing: 4) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text(journey.originStation.code)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                )
                .position(
                    x: geometry.size.width * 0.45,
                    y: geometry.size.height * 0.62
                )
            }
        }
    }

    // MARK: - Left Controls (Pause, Sound)

    private var leftControlsOverlay: some View {
        VStack {
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
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color(white: 0.2).opacity(0.7))
                        )
                }

                // Sound toggle button
                Button {
                    isSoundEnabled.toggle()
                } label: {
                    Image(systemName: isSoundEnabled ? "waveform" : "speaker.slash.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color(white: 0.2).opacity(0.7))
                        )
                }
            }
            .padding(.leading, 16)
            .padding(.top, 60)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Right Controls (Compass, Layers, Phone, Exit)

    private var rightControlsOverlay: some View {
        VStack {
            VStack(spacing: 10) {
                // Compass/North indicator
                Button {
                    // Not implemented yet
                } label: {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(white: 0.2).opacity(0.7))
                        )
                }

                // Map layers button (3D icon like screenshot)
                Button {
                    // Not implemented yet
                } label: {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(white: 0.2).opacity(0.7))
                        )
                }

                // Phone/device button (like screenshot)
                Button {
                    // Not implemented yet
                } label: {
                    Image(systemName: "iphone")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(white: 0.2).opacity(0.7))
                        )
                }

                // End journey button
                Button {
                    showEndConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(white: 0.2).opacity(0.7))
                        )
                }
            }
            .padding(.trailing, 16)
            .padding(.top, 60)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - Bottom Stats Bar

    private var bottomStatsBar: some View {
        HStack(alignment: .bottom) {
            // Time Remaining (left side)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 10))
                    Text("Maps")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Color.white.opacity(0.5))

                Text("Time Remaining")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text(formattedTimeRemaining)
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Distance Remaining (right side)
            VStack(alignment: .trailing, spacing: 2) {
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
        .padding(.bottom, 24)
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
            railPath = createSmoothPath(from: detailedRoute)
        } else if let route = TrainRoute.findRoute(from: origin, to: destination) {
            let stationCoords = getRouteCoordinates(route: route, from: origin, to: destination)
            railPath = createSmoothPath(from: stationCoords)
        } else {
            railPath = createCurvedPath(
                from: origin.locationCoordinate,
                to: destination.locationCoordinate
            )
        }

        currentPosition = railPath.first
        animatedProgress = 0
        updateCamera()
    }

    private func createSmoothPath(from waypoints: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard waypoints.count >= 2 else { return waypoints }

        var result: [CLLocationCoordinate2D] = []
        let pointsPerSegment = 30

        for i in 0..<waypoints.count - 1 {
            let start = waypoints[i]
            let end = waypoints[i + 1]

            for j in 0..<pointsPerSegment {
                let t = Double(j) / Double(pointsPerSegment)
                let lat = start.latitude + (end.latitude - start.latitude) * t
                let lon = start.longitude + (end.longitude - start.longitude) * t
                result.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }

        if let last = waypoints.last {
            result.append(last)
        }

        return result
    }

    private func getRouteCoordinates(route: TrainRoute, from origin: Station, to destination: Station) -> [CLLocationCoordinate2D] {
        guard let originIndex = route.stations.firstIndex(of: origin),
              let destIndex = route.stations.firstIndex(of: destination) else {
            return [origin.locationCoordinate, destination.locationCoordinate]
        }

        let startIndex = min(originIndex, destIndex)
        let endIndex = max(originIndex, destIndex)
        let stationSegment = Array(route.stations[startIndex...endIndex])
        let orderedStations = originIndex < destIndex ? stationSegment : stationSegment.reversed()

        return orderedStations.map { $0.locationCoordinate }
    }

    private func createCurvedPath(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> [CLLocationCoordinate2D] {
        var path: [CLLocationCoordinate2D] = []
        let segments = 150

        let midLat = (start.latitude + end.latitude) / 2
        let midLon = (start.longitude + end.longitude) / 2

        let deltaLat = end.latitude - start.latitude
        let deltaLon = end.longitude - start.longitude
        let perpLat = -deltaLon * 0.1
        let perpLon = deltaLat * 0.1

        let controlLat = midLat + perpLat
        let controlLon = midLon + perpLon

        for i in 0...segments {
            let t = Double(i) / Double(segments)
            let lat = pow(1-t, 2) * start.latitude + 2 * (1-t) * t * controlLat + pow(t, 2) * end.latitude
            let lon = pow(1-t, 2) * start.longitude + 2 * (1-t) * t * controlLon + pow(t, 2) * end.longitude
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

        let latDiff = abs(origin.latitude - destination.latitude)
        let lonDiff = abs(origin.longitude - destination.longitude)
        let maxDiff = max(latDiff, lonDiff)

        // Increase distance slightly to compensate for pitched view
        let distance = max(maxDiff * 200000, 500000)

        // Calculate heading from origin to destination for camera orientation
        let deltaLon = destination.longitude - origin.longitude
        let deltaLat = destination.latitude - origin.latitude
        let cameraHeading = atan2(deltaLon, deltaLat) * 180 / .pi

        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                distance: distance,
                heading: cameraHeading,
                pitch: 50  // Tilted view like flight tracker - looking across the map
            )
        )
    }

    private func updateTrainPosition(progress: Double) {
        guard railPath.count > 1 else { return }

        let exactIndex = Double(railPath.count - 1) * progress
        let lowerIndex = max(0, min(Int(exactIndex), railPath.count - 2))
        let upperIndex = lowerIndex + 1
        let fraction = exactIndex - Double(lowerIndex)

        let lowerCoord = railPath[lowerIndex]
        let upperCoord = railPath[upperIndex]

        let interpolatedLat = lowerCoord.latitude + (upperCoord.latitude - lowerCoord.latitude) * fraction
        let interpolatedLon = lowerCoord.longitude + (upperCoord.longitude - lowerCoord.longitude) * fraction
        let newPosition = CLLocationCoordinate2D(latitude: interpolatedLat, longitude: interpolatedLon)

        let lookAheadIndex = min(upperIndex + 2, railPath.count - 1)
        let lookAheadCoord = railPath[lookAheadIndex]
        trainHeading = calculateHeading(from: newPosition, to: lookAheadCoord)

        currentPosition = newPosition
    }

    private func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let deltaLon = to.longitude - from.longitude
        let deltaLat = to.latitude - from.latitude
        let angle = atan2(deltaLon, deltaLat) * 180 / .pi
        return angle
    }
}

// MARK: - Display Link Target

private class DisplayLinkTarget {
    private let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    @objc func update() {
        callback()
    }
}

// MARK: - Modern 3D Train Map Icon (CR400AF Fuxing Style)

struct ModernTrainMapIcon: View {
    let heading: Double

    var body: some View {
        ZStack {
            // Ground shadow (elongated ellipse)
            Ellipse()
                .fill(Color.black.opacity(0.35))
                .frame(width: 24, height: 50)
                .offset(x: 3, y: 4)
                .blur(radius: 4)

            // Main train body with 3D effect
            ZStack {
                // Base body shape - silver/white with 3D gradient
                BulletTrainBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.95),
                                Color(white: 0.85),
                                Color(white: 0.75),
                                Color(white: 0.85),
                                Color(white: 0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 18, height: 48)

                // Red/orange accent stripe (swooping design)
                BulletTrainAccentStripe()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.25, blue: 0.15),
                                Color(red: 0.95, green: 0.4, blue: 0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 18, height: 48)

                // Windshield/cockpit area (dark tinted)
                BulletTrainWindshield()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.2),
                                Color(white: 0.35),
                                Color(white: 0.25)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 18, height: 48)

                // Top highlight for 3D roundness
                BulletTrainHighlight()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 18, height: 48)

                // Edge outline
                BulletTrainBodyShape()
                    .stroke(Color(white: 0.5), lineWidth: 0.5)
                    .frame(width: 18, height: 48)
            }
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 2)
        }
        .rotationEffect(.degrees(heading))
    }
}

// MARK: - Bullet Train Body Shape (Elongated aerodynamic nose)

struct BulletTrainBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Ultra-sleek bullet nose pointing UP (like CR400AF Fuxing)
        // Very long, tapered nose section

        // Nose tip (sharp point)
        path.move(to: CGPoint(x: w * 0.5, y: 0))

        // Right nose curve - very elongated and aerodynamic
        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.28),
            control1: CGPoint(x: w * 0.52, y: h * 0.05),
            control2: CGPoint(x: w * 0.75, y: h * 0.15)
        )

        // Right body - slight taper toward rear
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.7),
            control1: CGPoint(x: w * 0.95, y: h * 0.4),
            control2: CGPoint(x: w * 0.9, y: h * 0.55)
        )

        // Right rear curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 0.85, y: h * 0.88),
            control2: CGPoint(x: w * 0.68, y: h * 0.98)
        )

        // Left rear curve
        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.7),
            control1: CGPoint(x: w * 0.32, y: h * 0.98),
            control2: CGPoint(x: w * 0.15, y: h * 0.88)
        )

        // Left body
        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.28),
            control1: CGPoint(x: w * 0.1, y: h * 0.55),
            control2: CGPoint(x: w * 0.05, y: h * 0.4)
        )

        // Left nose curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.25, y: h * 0.15),
            control2: CGPoint(x: w * 0.48, y: h * 0.05)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Accent Stripe (Red swooping design like Fuxing)

struct BulletTrainAccentStripe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Right side swooping stripe
        path.move(to: CGPoint(x: w * 0.7, y: h * 0.18))
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.35),
            control1: CGPoint(x: w * 0.78, y: h * 0.22),
            control2: CGPoint(x: w * 0.85, y: h * 0.28)
        )
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.55))
        path.addCurve(
            to: CGPoint(x: w * 0.6, y: h * 0.25),
            control1: CGPoint(x: w * 0.8, y: h * 0.4),
            control2: CGPoint(x: w * 0.7, y: h * 0.3)
        )
        path.closeSubpath()

        // Left side swooping stripe (mirror)
        path.move(to: CGPoint(x: w * 0.3, y: h * 0.18))
        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.35),
            control1: CGPoint(x: w * 0.22, y: h * 0.22),
            control2: CGPoint(x: w * 0.15, y: h * 0.28)
        )
        path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.55))
        path.addCurve(
            to: CGPoint(x: w * 0.4, y: h * 0.25),
            control1: CGPoint(x: w * 0.2, y: h * 0.4),
            control2: CGPoint(x: w * 0.3, y: h * 0.3)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Windshield Area

struct BulletTrainWindshield: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Sleek windshield at the nose
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.02))
        path.addCurve(
            to: CGPoint(x: w * 0.65, y: h * 0.15),
            control1: CGPoint(x: w * 0.55, y: h * 0.05),
            control2: CGPoint(x: w * 0.6, y: h * 0.1)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.2),
            control1: CGPoint(x: w * 0.6, y: h * 0.18),
            control2: CGPoint(x: w * 0.55, y: h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.15),
            control1: CGPoint(x: w * 0.45, y: h * 0.2),
            control2: CGPoint(x: w * 0.4, y: h * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.02),
            control1: CGPoint(x: w * 0.4, y: h * 0.1),
            control2: CGPoint(x: w * 0.45, y: h * 0.05)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Top Highlight for 3D Effect

struct BulletTrainHighlight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Center highlight strip running along the top
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.01))
        path.addCurve(
            to: CGPoint(x: w * 0.6, y: h * 0.3),
            control1: CGPoint(x: w * 0.52, y: h * 0.1),
            control2: CGPoint(x: w * 0.58, y: h * 0.2)
        )
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.6))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.6))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.3))
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.01),
            control1: CGPoint(x: w * 0.42, y: h * 0.2),
            control2: CGPoint(x: w * 0.48, y: h * 0.1)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Legacy Shape (kept for compatibility)

struct RealisticBulletTrainShape: Shape {
    func path(in rect: CGRect) -> Path {
        BulletTrainBodyShape().path(in: rect)
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
