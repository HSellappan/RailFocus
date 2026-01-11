//
//  NewHomeView.swift
//  RailFocus
//
//  Home screen with European rail map and side menu
//

import SwiftUI
import MapKit

struct NewHomeView: View {
    @Environment(\.appState) private var appState
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showMenu = false
    @State private var showBookingSheet = false
    @State private var showRideMode = false
    @State private var showArrivalScreen = false
    @State private var showHomeStationPicker = false
    @State private var showDestinationPicker = false
    @State private var showSeatSelection = false
    @State private var pendingSeat: String?
    @State private var pendingFocusTag: FocusTag?

    var body: some View {
        ZStack {
            // Europe-focused rail map
            EuropeRailMapView(mapStyle: appState.settings.mapStyle)
                .ignoresSafeArea()

            // Stars overlay (subtle)
            StarsBackgroundView()
                .opacity(0.2)
                .allowsHitTesting(false)

            // Content overlay
            VStack(alignment: .leading, spacing: 0) {
                // Top greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.settings.greeting)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.6))

                    if let homeStation = appState.settings.homeStation {
                        Text(homeStation.city)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("Europe")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal, 24)

                Spacer()

                // Bottom section
                VStack(alignment: .leading, spacing: 16) {
                    // Home station indicator (if set)
                    if let homeStation = appState.settings.homeStation {
                        HStack(spacing: 8) {
                            Text(homeStation.countryFlag)
                                .font(.system(size: 16))
                            Text(homeStation.code)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.black)
                            Text("•")
                                .foregroundStyle(Color.white.opacity(0.3))
                            Text(homeStation.railLine)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                        )
                    }

                    // Start Journey button
                    Button {
                        beginJourney()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "train.side.front.car")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Begin Journey")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.black)
                        .frame(width: 200, height: 50)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                    }

                    // Side menu
                    SideMenuView(selectedItem: .constant(appState.selectedMenuItem))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }

            // Maps attribution
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Maps")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.4))
                    Text("Legal")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.4))
                }
                .padding(.trailing, 8)
                .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(.dark)
        // Home station picker (first time)
        .fullScreenCover(isPresented: $showHomeStationPicker) {
            HomeStationPickerView { station in
                appState.settings.homeStation = station
                showHomeStationPicker = false
                // After setting home station, show destination picker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showDestinationPicker = true
                }
            }
        }
        // Destination picker
        .fullScreenCover(isPresented: $showDestinationPicker) {
            if let homeStation = appState.settings.homeStation {
                DestinationPickerView(originStation: homeStation) { destination, connection, duration in
                    // Create journey and show seat selection
                    let journey = Journey(
                        origin: homeStation,
                        destination: destination,
                        duration: TimeInterval(duration * 60)
                    )
                    appState.pendingJourney = journey
                    showDestinationPicker = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSeatSelection = true
                    }
                }
            }
        }
        // Seat selection
        .fullScreenCover(isPresented: $showSeatSelection) {
            if let journey = appState.pendingJourney {
                TrainSeatSelectionView(journey: journey) { seat, focusTag in
                    pendingSeat = seat
                    pendingFocusTag = focusTag
                    showSeatSelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.showBoardingTicket = true
                    }
                }
            }
        }
        // Legacy booking sheet (for fallback)
        .sheet(isPresented: $showBookingSheet) {
            JourneyBookingSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showRideMode) {
            RideModeView()
        }
        .fullScreenCover(isPresented: $showArrivalScreen) {
            ArrivalView()
        }
        .fullScreenCover(isPresented: Binding(
            get: { appState.showBoardingTicket },
            set: { appState.showBoardingTicket = $0 }
        )) {
            if let journey = appState.pendingJourney {
                BoardingTicketView(
                    journey: journey,
                    seat: pendingSeat,
                    focusTag: pendingFocusTag
                ) {
                    appState.showBoardingTicket = false
                    appState.startJourney(journey)
                    // Clear pending seat data
                    pendingSeat = nil
                    pendingFocusTag = nil
                }
            }
        }
        .onChange(of: appState.showBookingSheet) { _, newValue in
            showBookingSheet = newValue
        }
        .onChange(of: appState.showRideMode) { _, newValue in
            showRideMode = newValue
        }
        .onChange(of: appState.showArrivalScreen) { _, newValue in
            showArrivalScreen = newValue
        }
        .onChange(of: showBookingSheet) { _, newValue in
            appState.showBookingSheet = newValue
        }
    }

    // MARK: - Begin Journey Flow

    private func beginJourney() {
        if appState.settings.hasSetHomeStation {
            // User has home station, show destination picker
            showDestinationPicker = true
        } else {
            // First time, show home station picker
            showHomeStationPicker = true
        }
    }
}

// MARK: - Europe Rail Map View

struct EuropeRailMapView: View {
    let mapStyle: RFMapStyle

    // Europe center (roughly central Europe)
    private let europeCenter = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)
    private let europeDistance: Double = 5000000 // ~5000km view

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var animatedTrainPosition: Double = 0

    var body: some View {
        Map(position: $cameraPosition) {
            // Draw all European rail lines with clean blue color
            ForEach(EuropeanRailNetwork.allLines) { line in
                MapPolyline(coordinates: line.waypoints)
                    .stroke(Color(hex: line.color).opacity(0.7), lineWidth: 2)
            }

            // Station markers (small white dots)
            ForEach(Station.europeStations) { station in
                Annotation("", coordinate: station.locationCoordinate) {
                    SmallStationDot()
                }
            }

            // Animated train on Eurostar route (demo)
            let eurostarWaypoints = EuropeanRailNetwork.eurostar.waypoints
            if eurostarWaypoints.count >= 2 {
                Annotation("", coordinate: interpolatedPosition(on: eurostarWaypoints, progress: animatedTrainPosition)) {
                    ModernTrainIcon()
                }
            }
        }
        .mapStyle(mapStyleConfiguration)
        .onAppear {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: europeCenter,
                    distance: europeDistance,
                    heading: 0,
                    pitch: 0
                )
            )

            // Start train animation
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: true)
            ) {
                animatedTrainPosition = 1.0
            }
        }
    }

    private var mapStyleConfiguration: MapKit.MapStyle {
        switch mapStyle {
        case .monochrome:
            return .standard(elevation: .realistic, emphasis: .muted)
        case .terra:
            return .standard(elevation: .realistic)
        case .standard:
            return .standard(elevation: .realistic)
        case .satellite:
            return .imagery(elevation: .realistic)
        }
    }

    // Interpolate position along route
    private func interpolatedPosition(on waypoints: [CLLocationCoordinate2D], progress: Double) -> CLLocationCoordinate2D {
        guard waypoints.count >= 2 else {
            return waypoints.first ?? europeCenter
        }

        let totalSegments = waypoints.count - 1
        let segmentProgress = progress * Double(totalSegments)
        let segmentIndex = min(Int(segmentProgress), totalSegments - 1)
        let localProgress = segmentProgress - Double(segmentIndex)

        let start = waypoints[segmentIndex]
        let end = waypoints[min(segmentIndex + 1, waypoints.count - 1)]

        return CLLocationCoordinate2D(
            latitude: start.latitude + (end.latitude - start.latitude) * localProgress,
            longitude: start.longitude + (end.longitude - start.longitude) * localProgress
        )
    }
}

// MARK: - Small Station Dot (for clean map display)

struct SmallStationDot: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 6, height: 6)
            .shadow(color: Color.black.opacity(0.3), radius: 2)
    }
}

// MARK: - Station Marker View

struct StationMarkerView: View {
    let station: Station

    var body: some View {
        VStack(spacing: 2) {
            // Station dot
            Circle()
                .fill(railLineColor)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: railLineColor.opacity(0.5), radius: 3)
        }
    }

    private var railLineColor: Color {
        switch station.railLine {
        case "TGV": return Color(hex: "9B2335")
        case "ICE": return Color(hex: "EC0016")
        case "Eurostar": return Color(hex: "FFCD00")
        case "AVE": return Color(hex: "6B2C91")
        case "Frecciarossa": return Color(hex: "C8102E")
        case "Thalys": return Color(hex: "9B2335")
        case "SBB": return Color.red
        case "ÖBB": return Color.red
        default: return .white
        }
    }
}

// MARK: - Modern Train Icon

struct ModernTrainIcon: View {
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(Color.rfElectricBlue.opacity(0.3))
                .frame(width: 36, height: 36)
                .blur(radius: 4)
                .scaleEffect(isGlowing ? 1.2 : 1.0)

            // Train body
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.rfElectricBlue,
                                Color.rfElectricBlue.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 28, height: 18)

                // Front light
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .offset(x: 8)

                // Windows
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 4, height: 6)
                    }
                }
                .offset(x: -4)
            }
            .shadow(color: Color.rfElectricBlue.opacity(0.5), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Side Menu View

struct SideMenuView: View {
    @Binding var selectedItem: MenuItem

    private let menuItems: [MenuItem] = [.inProgress, .history, .trends, .settings]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(menuItems) { item in
                Button {
                    selectedItem = item
                } label: {
                    Text(item.title)
                        .font(.system(size: 17, weight: selectedItem == item ? .semibold : .regular))
                        .foregroundStyle(selectedItem == item ? .white : Color.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                }
            }
        }
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                )
        )
    }
}

// MARK: - Journey Booking Sheet

struct JourneyBookingSheet: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedOrigin: Station = .parisGareDeLyon
    @State private var selectedDestination: Station = .lyonPartDieu
    @State private var selectedDuration: Int = 25
    @State private var selectedTag: FocusTag?
    @State private var showOriginPicker = false
    @State private var showDestinationPicker = false

    private let durationOptions = [25, 45, 60, 90]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Route selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Route")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.6))

                            HStack(spacing: 12) {
                                // Origin
                                StationSelectButton(
                                    station: selectedOrigin,
                                    label: "From"
                                ) {
                                    showOriginPicker = true
                                }

                                // Swap button
                                Button {
                                    let temp = selectedOrigin
                                    selectedOrigin = selectedDestination
                                    selectedDestination = temp
                                } label: {
                                    Image(systemName: "arrow.left.arrow.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.white.opacity(0.6))
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                        )
                                }

                                // Destination
                                StationSelectButton(
                                    station: selectedDestination,
                                    label: "To"
                                ) {
                                    showDestinationPicker = true
                                }
                            }
                        }

                        // Route info
                        if let route = TrainRoute.findRoute(from: selectedOrigin, to: selectedDestination) {
                            RouteInfoBadge(route: route, origin: selectedOrigin, destination: selectedDestination)
                        }

                        // Duration selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Focus Duration")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.6))

                            HStack(spacing: 12) {
                                ForEach(durationOptions, id: \.self) { duration in
                                    DurationButton(
                                        minutes: duration,
                                        isSelected: selectedDuration == duration
                                    ) {
                                        selectedDuration = duration
                                    }
                                }
                            }
                        }

                        // Tag selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tag (optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.6))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(FocusTag.allCases) { tag in
                                        TagButton(
                                            tag: tag,
                                            isSelected: selectedTag == tag
                                        ) {
                                            selectedTag = selectedTag == tag ? nil : tag
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 40)

                        // Get Ticket button
                        Button {
                            showTicket()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 16))
                                Text("Get Ticket")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Book Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showOriginPicker) {
            StationPickerView(
                selectedStation: $selectedOrigin,
                title: "Select Origin",
                excludeStation: selectedDestination
            )
        }
        .sheet(isPresented: $showDestinationPicker) {
            StationPickerView(
                selectedStation: $selectedDestination,
                title: "Select Destination",
                excludeStation: selectedOrigin
            )
        }
    }

    private func showTicket() {
        let journey = Journey(
            origin: selectedOrigin,
            destination: selectedDestination,
            duration: TimeInterval(selectedDuration * 60),
            tag: selectedTag
        )
        appState.pendingJourney = journey
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appState.showBoardingTicket = true
        }
    }
}

// MARK: - Station Select Button

struct StationSelectButton: View {
    let station: Station
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.4))

                HStack(spacing: 8) {
                    Text(station.countryFlag)
                        .font(.system(size: 18))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.code)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text(station.city)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }

                Text(station.railLine)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Route Info Badge

struct RouteInfoBadge: View {
    let route: TrainRoute
    let origin: Station
    let destination: Station

    var body: some View {
        HStack(spacing: 12) {
            // Route color indicator
            Circle()
                .fill(Color(hex: route.color))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(route.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Text("\(origin.city) → \(destination.city)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.6))
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.rfSuccess)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Duration Button

struct DurationButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes)m")
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                )
        }
    }
}

// MARK: - Tag Button

struct TagButton: View {
    let tag: FocusTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: tag.icon)
                    .font(.system(size: 12))
                Text(tag.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.08))
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NewHomeView()
        .environment(\.appState, AppState())
}
