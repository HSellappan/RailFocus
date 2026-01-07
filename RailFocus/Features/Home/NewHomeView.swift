//
//  NewHomeView.swift
//  RailFocus
//
//  Home screen with 3D globe and side menu
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

    var body: some View {
        ZStack {
            // Globe map background
            GlobeMapView(
                userLatitude: appState.settings.userLatitude,
                userLongitude: appState.settings.userLongitude,
                mapStyle: appState.settings.mapStyle
            )
            .ignoresSafeArea()

            // Stars overlay
            StarsBackgroundView()
                .opacity(0.3)
                .allowsHitTesting(false)

            // Content overlay
            VStack(alignment: .leading, spacing: 0) {
                // Top greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.settings.greeting)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.6))

                    Text(appState.settings.userCity)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 60)
                .padding(.horizontal, 24)

                Spacer()

                // Bottom section
                VStack(alignment: .leading, spacing: 16) {
                    // Start Journey button
                    Button {
                        showBookingSheet = true
                    } label: {
                        Text("Start Journey")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: 180, height: 50)
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
                BoardingTicketView(journey: journey) {
                    // On board - start the actual journey
                    appState.showBoardingTicket = false
                    appState.startJourney(journey)
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
}

// MARK: - Globe Map View

struct GlobeMapView: View {
    let userLatitude: Double
    let userLongitude: Double
    let mapStyle: RFMapStyle

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition) {
            // User location marker - realistic train station pin
            Annotation("", coordinate: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)) {
                TrainStationMarker()
            }
        }
        .mapStyle(mapStyleConfiguration)
        .onAppear {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude),
                    distance: 20000000,
                    heading: 0,
                    pitch: 0
                )
            )
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
}

// MARK: - Train Station Marker

struct TrainStationMarker: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .stroke(Color.rfElectricBlue.opacity(0.3), lineWidth: 2)
                .frame(width: 44, height: 44)
                .scaleEffect(isPulsing ? 1.3 : 1.0)
                .opacity(isPulsing ? 0 : 0.6)

            // Middle ring
            Circle()
                .fill(Color.rfElectricBlue.opacity(0.15))
                .frame(width: 36, height: 36)

            // Inner circle with train icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.rfElectricBlue, Color.rfElectricBlue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 28, height: 28)
                    .shadow(color: Color.rfElectricBlue.opacity(0.5), radius: 4, x: 0, y: 2)

                Image(systemName: "train.side.front.car")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Pin point indicator
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 36)
                Triangle()
                    .fill(Color.rfElectricBlue)
                    .frame(width: 10, height: 6)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                isPulsing = true
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

    @State private var selectedOrigin: Station = .tokyo
    @State private var selectedDestination: Station = .osaka
    @State private var selectedDuration: Int = 25
    @State private var selectedTag: FocusTag?

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

                            HStack {
                                // Origin
                                StationButton(station: selectedOrigin, label: "From") {
                                    // Show station picker
                                }

                                Image(systemName: "arrow.right")
                                    .foregroundStyle(Color.white.opacity(0.4))

                                // Destination
                                StationButton(station: selectedDestination, label: "To") {
                                    // Show station picker
                                }
                            }
                        }

                        // Duration selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration")
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

                        // Start button
                        Button {
                            showTicket()
                        } label: {
                            Text("Get Ticket")
                                .font(.system(size: 17, weight: .semibold))
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

// MARK: - Supporting Components

struct StationButton: View {
    let station: Station
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.4))

                Text(station.code)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text(station.city)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }
}

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
