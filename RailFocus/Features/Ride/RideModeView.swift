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
    @State private var mapCameraHeading: Double = 0  // Store camera heading for train orientation
    @State private var isSoundEnabled = true
    @State private var displayLink: CADisplayLink?
    @State private var animatedProgress: Double = 0
    @State private var lastUpdateTime: CFTimeInterval = 0

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
        lastUpdateTime = CACurrentMediaTime()
        animatedProgress = 0

        let link = CADisplayLink(target: DisplayLinkTarget { [self] in
            self.updateFrame()
        }, selector: #selector(DisplayLinkTarget.update))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func updateFrame() {
        // Only update when running
        guard appState.timerService.state == .running else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Calculate speed based on journey duration for smooth constant movement
        guard let journey = appState.activeJourney else { return }
        let totalDuration = Double(journey.scheduledDuration)

        // Linear progress increment for constant speed
        let progressIncrement = deltaTime / totalDuration
        animatedProgress += progressIncrement

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

            // 3-car train marker (moves along the route)
            if let position = currentPosition {
                Annotation("", coordinate: position, anchor: .center) {
                    ThreeCarTrainIcon(heading: trainHeading, cameraHeading: mapCameraHeading)
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

        // Store camera heading for train orientation correction
        mapCameraHeading = cameraHeading

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

        // Use more look-ahead points for smoother heading calculation
        let lookAheadIndex = min(upperIndex + 5, railPath.count - 1)
        let lookAheadCoord = railPath[lookAheadIndex]
        let newHeading = calculateHeading(from: newPosition, to: lookAheadCoord)

        // Smooth heading transitions to prevent jittery rotation
        let headingDiff = newHeading - trainHeading
        var normalizedDiff = headingDiff
        if normalizedDiff > 180 { normalizedDiff -= 360 }
        if normalizedDiff < -180 { normalizedDiff += 360 }
        trainHeading += normalizedDiff * 0.15

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

// MARK: - 3-Car Train Icon (Front Locomotive + 2 Passenger Cars)

struct ThreeCarTrainIcon: View {
    let heading: Double
    let cameraHeading: Double

    // Calculate visual heading (relative to camera orientation)
    private var visualHeading: Double {
        heading - cameraHeading
    }

    private let carWidth: CGFloat = 14
    private let locomotiveLength: CGFloat = 28
    private let passengerCarLength: CGFloat = 22
    private let carGap: CGFloat = 2

    var body: some View {
        ZStack {
            // Ground shadow
            Capsule()
                .fill(Color.black.opacity(0.3))
                .frame(width: carWidth + 4, height: locomotiveLength + (passengerCarLength * 2) + (carGap * 2) + 8)
                .offset(x: 2, y: 3)
                .blur(radius: 4)

            // Train cars (front to back: locomotive, car 1, car 2)
            VStack(spacing: carGap) {
                // Front Locomotive (with aerodynamic nose)
                LocomotiveCar()
                    .frame(width: carWidth, height: locomotiveLength)

                // Passenger Car 1
                PassengerCar()
                    .frame(width: carWidth, height: passengerCarLength)

                // Passenger Car 2 (rear)
                PassengerCar()
                    .frame(width: carWidth, height: passengerCarLength)
            }
            .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 1)
        }
        .rotationEffect(.degrees(visualHeading))
    }
}

// MARK: - Locomotive Car (Front with aerodynamic nose)

struct LocomotiveCar: View {
    var body: some View {
        ZStack {
            // Main body
            LocomotiveShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.96),
                            Color(white: 0.88),
                            Color(white: 0.78),
                            Color(white: 0.88),
                            Color(white: 0.96)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Red accent stripe
            LocomotiveStripe()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.15, blue: 0.1),
                            Color(red: 0.95, green: 0.35, blue: 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Windshield
            LocomotiveWindshield()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.15),
                            Color(white: 0.3),
                            Color(white: 0.2)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Top highlight
            LocomotiveShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )

            // Outline
            LocomotiveShape()
                .stroke(Color(white: 0.55), lineWidth: 0.5)
        }
    }
}

// MARK: - Passenger Car

struct PassengerCar: View {
    var body: some View {
        ZStack {
            // Main body
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.96),
                            Color(white: 0.88),
                            Color(white: 0.78),
                            Color(white: 0.88),
                            Color(white: 0.96)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Red stripe along the side
            PassengerCarStripe()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.15, blue: 0.1),
                            Color(red: 0.95, green: 0.35, blue: 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Windows (row of small rectangles)
            PassengerCarWindows()
                .fill(Color(white: 0.25))

            // Top highlight
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )

            // Outline
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(white: 0.55), lineWidth: 0.5)
        }
    }
}

// MARK: - Locomotive Shape

struct LocomotiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Aerodynamic bullet nose pointing UP
        path.move(to: CGPoint(x: w * 0.5, y: 0))

        // Right nose curve
        path.addCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.25),
            control1: CGPoint(x: w * 0.52, y: h * 0.03),
            control2: CGPoint(x: w * 0.75, y: h * 0.12)
        )

        // Right body
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.92))

        // Right rear corner
        path.addQuadCurve(
            to: CGPoint(x: w * 0.75, y: h),
            control: CGPoint(x: w * 0.9, y: h)
        )

        // Bottom
        path.addLine(to: CGPoint(x: w * 0.25, y: h))

        // Left rear corner
        path.addQuadCurve(
            to: CGPoint(x: w * 0.1, y: h * 0.92),
            control: CGPoint(x: w * 0.1, y: h)
        )

        // Left body
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.25))

        // Left nose curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.25, y: h * 0.12),
            control2: CGPoint(x: w * 0.48, y: h * 0.03)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Locomotive Stripe

struct LocomotiveStripe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Right stripe
        path.move(to: CGPoint(x: w * 0.65, y: h * 0.12))
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.3),
            control1: CGPoint(x: w * 0.75, y: h * 0.15),
            control2: CGPoint(x: w * 0.85, y: h * 0.22)
        )
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.2))
        path.closeSubpath()

        // Left stripe
        path.move(to: CGPoint(x: w * 0.35, y: h * 0.12))
        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.3),
            control1: CGPoint(x: w * 0.25, y: h * 0.15),
            control2: CGPoint(x: w * 0.15, y: h * 0.22)
        )
        path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.2))
        path.closeSubpath()

        return path
    }
}

// MARK: - Locomotive Windshield

struct LocomotiveWindshield: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: h * 0.02))
        path.addCurve(
            to: CGPoint(x: w * 0.62, y: h * 0.12),
            control1: CGPoint(x: w * 0.54, y: h * 0.04),
            control2: CGPoint(x: w * 0.58, y: h * 0.08)
        )
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.18))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.18))
        path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.12))
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.02),
            control1: CGPoint(x: w * 0.42, y: h * 0.08),
            control2: CGPoint(x: w * 0.46, y: h * 0.04)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Passenger Car Stripe

struct PassengerCarStripe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Right stripe
        path.addRect(CGRect(x: w * 0.82, y: h * 0.15, width: w * 0.08, height: h * 0.7))

        // Left stripe
        path.addRect(CGRect(x: w * 0.1, y: h * 0.15, width: w * 0.08, height: h * 0.7))

        return path
    }
}

// MARK: - Passenger Car Windows

struct PassengerCarWindows: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Small windows along the car
        let windowWidth = w * 0.15
        let windowHeight = h * 0.12
        let windowY = h * 0.35

        // Window positions
        let positions: [CGFloat] = [0.2, 0.5, 0.8]
        for pos in positions {
            let centerX = w * pos
            path.addRoundedRect(
                in: CGRect(
                    x: centerX - windowWidth / 2,
                    y: windowY,
                    width: windowWidth,
                    height: windowHeight
                ),
                cornerSize: CGSize(width: 1, height: 1)
            )
        }

        return path
    }
}

// MARK: - Legacy compatibility

struct ModernTrainMapIcon: View {
    let heading: Double

    var body: some View {
        ThreeCarTrainIcon(heading: heading, cameraHeading: 0)
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
