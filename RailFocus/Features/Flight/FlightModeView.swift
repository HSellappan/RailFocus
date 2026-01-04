//
//  FlightModeView.swift
//  RailFocus
//
//  Full-screen immersive focus session view
//

import SwiftUI
import MapKit

struct FlightModeView: View {
    @Environment(\.appState) private var appState
    @State private var showEndConfirmation = false
    @State private var flightPath: [CLLocationCoordinate2D] = []
    @State private var currentPosition: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            // Map background with flight path
            flightMapView
                .ignoresSafeArea()

            // Stars overlay
            StarsBackgroundView()
                .opacity(0.2)
                .allowsHitTesting(false)

            // Content overlay
            VStack(spacing: 0) {
                // Top bar
                topBar

                Spacer()

                // Center time display
                centerTimeDisplay

                Spacer()

                // Bottom controls
                bottomControls
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupFlightPath()
        }
        .onChange(of: appState.timerService.progress) { _, newValue in
            updatePlanePosition(progress: newValue)
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

    // MARK: - Flight Map

    private var flightMapView: some View {
        Map(position: $cameraPosition) {
            // Flight path line
            if flightPath.count >= 2 {
                MapPolyline(coordinates: flightPath)
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
            }

            // Origin marker
            if let journey = appState.activeJourney {
                Annotation("", coordinate: journey.originStation.locationCoordinate) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }

                // Destination marker
                Annotation("", coordinate: journey.destinationStation.locationCoordinate) {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 10, height: 10)
                }

                // Plane marker
                if let position = currentPosition {
                    Annotation("", coordinate: position) {
                        Image(systemName: "airplane")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(calculateHeading()))
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Route info
            if let journey = appState.activeJourney {
                VStack(alignment: .leading, spacing: 2) {
                    Text(journey.routeCode)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    if let tag = journey.tag {
                        HStack(spacing: 4) {
                            Image(systemName: tag.icon)
                                .font(.system(size: 10))
                            Text(tag.displayName)
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
            }

            Spacer()

            // Status badge
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(statusText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }

    // MARK: - Center Time Display

    private var centerTimeDisplay: some View {
        VStack(spacing: 8) {
            Text(appState.timerService.formattedTimeRemaining)
                .font(.system(size: 72, weight: .light, design: .monospaced))
                .foregroundStyle(.white)

            Text("remaining")
                .font(.system(size: 16))
                .foregroundStyle(Color.white.opacity(0.5))

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * appState.timerService.progress, height: 4)
                        .animation(.linear(duration: 1), value: appState.timerService.progress)
                }
            }
            .frame(height: 4)
            .frame(maxWidth: 200)
            .padding(.top, 16)
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Stats row
            if let journey = appState.activeJourney {
                HStack(spacing: 32) {
                    StatItem(
                        value: String(format: "%.0f", journey.distanceMiles * (1 - appState.timerService.progress)),
                        unit: "mi",
                        label: "Remaining"
                    )

                    StatItem(
                        value: "485",
                        unit: "mph",
                        label: "Speed"
                    )

                    StatItem(
                        value: "35,000",
                        unit: "ft",
                        label: "Altitude"
                    )
                }
            }

            // Control buttons
            HStack(spacing: 16) {
                // Pause/Resume button
                Button {
                    if appState.timerService.state == .running {
                        appState.timerService.pause()
                    } else {
                        appState.timerService.resume()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: appState.timerService.state == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(appState.timerService.state == .running ? "Pause" : "Resume")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
                }

                // End button
                Button {
                    showEndConfirmation = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text("End")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 100, height: 50)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch appState.timerService.state {
        case .running: return .rfSuccess
        case .paused: return .rfWarning
        default: return .white
        }
    }

    private var statusText: String {
        switch appState.timerService.state {
        case .running: return "IN FLIGHT"
        case .paused: return "PAUSED"
        default: return "READY"
        }
    }

    private func setupFlightPath() {
        guard let journey = appState.activeJourney else { return }

        let origin = journey.originStation.locationCoordinate
        let destination = journey.destinationStation.locationCoordinate

        // Create curved path between origin and destination
        flightPath = createGreatCirclePath(from: origin, to: destination, segments: 50)
        currentPosition = origin

        // Set camera to show full path
        let centerLat = (origin.latitude + destination.latitude) / 2
        let centerLon = (origin.longitude + destination.longitude) / 2

        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                distance: 15000000
            )
        )
    }

    private func updatePlanePosition(progress: Double) {
        guard flightPath.count > 1 else { return }

        let index = Int(Double(flightPath.count - 1) * progress)
        let clampedIndex = min(max(index, 0), flightPath.count - 1)
        currentPosition = flightPath[clampedIndex]
    }

    private func calculateHeading() -> Double {
        guard flightPath.count > 1, let current = currentPosition else { return 0 }

        let index = flightPath.firstIndex { coord in
            abs(coord.latitude - current.latitude) < 0.01 &&
            abs(coord.longitude - current.longitude) < 0.01
        } ?? 0

        let nextIndex = min(index + 1, flightPath.count - 1)
        let next = flightPath[nextIndex]

        let deltaLon = next.longitude - current.longitude
        let deltaLat = next.latitude - current.latitude

        return atan2(deltaLon, deltaLat) * 180 / .pi
    }

    private func createGreatCirclePath(
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
}

// MARK: - Stat Item

private struct StatItem: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.5))
        }
    }
}

// MARK: - Preview

#Preview {
    FlightModeView()
        .environment(\.appState, {
            let state = AppState()
            state.activeJourney = Journey(
                origin: .london,
                destination: .paris,
                duration: 1500
            )
            return state
        }())
}
