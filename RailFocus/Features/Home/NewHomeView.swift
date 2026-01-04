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
                        appState.showBookingSheet = true
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
                    SideMenuView(selectedItem: $appState.selectedMenuItem)
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
        .sheet(isPresented: $appState.showBookingSheet) {
            JourneyBookingSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $appState.showRideMode) {
            RideModeView()
        }
        .fullScreenCover(isPresented: $appState.showArrivalScreen) {
            ArrivalView()
        }
    }
}

// MARK: - Globe Map View

struct GlobeMapView: View {
    let userLatitude: Double
    let userLongitude: Double
    let mapStyle: MapStyle

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition) {
            // User location marker
            Annotation("", coordinate: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: 20, height: 20)
                    )
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

    private var mapStyleConfiguration: SwiftUI.MapStyle {
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
                            startJourney()
                        } label: {
                            Text("Start Journey")
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

    private func startJourney() {
        let journey = Journey(
            origin: selectedOrigin,
            destination: selectedDestination,
            duration: TimeInterval(selectedDuration * 60),
            tag: selectedTag
        )
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appState.startJourney(journey)
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
