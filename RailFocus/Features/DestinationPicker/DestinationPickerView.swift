//
//  DestinationPickerView.swift
//  RailFocus
//
//  Map-based destination picker with real European rail routes
//

import SwiftUI
import MapKit

struct DestinationPickerView: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismiss) private var dismiss

    let originStation: Station
    let onSelect: (Station, RailConnection, Int) -> Void

    @State private var selectedDestination: Station?
    @State private var selectedConnection: RailConnection?
    @State private var selectedDuration: Int = 25
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var trainProgress: Double = 0

    private var availableDestinations: [(station: Station, connection: RailConnection)] {
        RailConnection.destinations(from: originStation)
    }

    var body: some View {
        ZStack {
            // Map background
            destinationMap
                .ignoresSafeArea()

            // Overlay content
            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.top, 60)
                    .padding(.horizontal, 20)

                Spacer()

                // Bottom section
                VStack(spacing: 16) {
                    // Duration timeline
                    durationTimeline
                        .padding(.horizontal, 20)

                    // Destination cards carousel
                    destinationCarousel

                    // Book button
                    bookButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
                .background(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.8), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupInitialSelection()
            startTrainAnimation()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
            }

            Spacer()

            // Origin station badge
            HStack(spacing: 8) {
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 14))
                Text(originStation.code)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(hex: railLineColor(originStation.railLine)) ?? .yellow)
            )

            Spacer()

            Button {
                // Search/filter
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    )
            }
        }
    }

    // MARK: - Map View

    private var destinationMap: some View {
        Map(position: $cameraPosition) {
            // Origin station marker
            Annotation("", coordinate: originStation.locationCoordinate) {
                OriginStationMarker(station: originStation)
            }

            // Route lines to all destinations
            ForEach(availableDestinations, id: \.station.id) { dest in
                MapPolyline(coordinates: [
                    originStation.locationCoordinate,
                    dest.station.locationCoordinate
                ])
                .stroke(
                    selectedDestination?.id == dest.station.id
                        ? Color.white
                        : Color.white.opacity(0.3),
                    lineWidth: selectedDestination?.id == dest.station.id ? 3 : 1.5
                )
            }

            // Destination station markers
            ForEach(availableDestinations, id: \.station.id) { dest in
                Annotation("", coordinate: dest.station.locationCoordinate) {
                    DestinationStationMarker(
                        station: dest.station,
                        travelTime: dest.connection.formattedTime,
                        isSelected: selectedDestination?.id == dest.station.id
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDestination = dest.station
                            selectedConnection = dest.connection
                        }
                    }
                }
            }

            // Animated train on selected route
            if let destination = selectedDestination {
                let trainCoord = interpolatedPosition(
                    from: originStation.locationCoordinate,
                    to: destination.locationCoordinate,
                    progress: trainProgress
                )
                Annotation("", coordinate: trainCoord) {
                    AnimatedTrainMarker()
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .onAppear {
            centerMapOnOrigin()
        }
    }

    // MARK: - Duration Timeline

    private var durationTimeline: some View {
        VStack(spacing: 8) {
            // Current duration indicator
            HStack {
                Spacer()
                VStack(spacing: 2) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.white)
                    Text("\(selectedDuration)m")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                }
                .offset(x: durationOffset)
                Spacer()
            }

            // Timeline slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 2)

                    // Tick marks
                    HStack(spacing: 0) {
                        ForEach(timelineMarks, id: \.self) { mark in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(mark.isMajor ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 1, height: mark.isMajor ? 12 : 6)
                            }
                            if mark.minutes != 90 {
                                Spacer()
                            }
                        }
                    }

                    // Duration labels
                    HStack {
                        ForEach([25, 45, 60, 90], id: \.self) { minutes in
                            Text(formatDuration(minutes))
                                .font(.system(size: 10))
                                .foregroundStyle(Color.white.opacity(0.5))
                            if minutes != 90 {
                                Spacer()
                            }
                        }
                    }
                    .offset(y: 20)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let progress = value.location.x / geometry.size.width
                            selectedDuration = durationFromProgress(progress)
                        }
                )
            }
            .frame(height: 40)
        }
    }

    // MARK: - Destination Carousel

    private var destinationCarousel: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableDestinations, id: \.station.id) { dest in
                        DestinationCard(
                            station: dest.station,
                            connection: dest.connection,
                            isSelected: selectedDestination?.id == dest.station.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDestination = dest.station
                                selectedConnection = dest.connection
                            }
                        }
                        .id(dest.station.id)
                    }
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: selectedDestination) { _, newValue in
                if let station = newValue {
                    withAnimation {
                        proxy.scrollTo(station.id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Book Button

    private var bookButton: some View {
        Button {
            if let destination = selectedDestination,
               let connection = selectedConnection {
                onSelect(destination, connection, selectedDuration)
            }
        } label: {
            Text("Book My Train")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(selectedDestination != nil ? Color.white : Color.white.opacity(0.3))
                )
        }
        .disabled(selectedDestination == nil)
    }

    // MARK: - Helper Methods

    private func setupInitialSelection() {
        if let first = availableDestinations.first {
            selectedDestination = first.station
            selectedConnection = first.connection
        }
    }

    private func centerMapOnOrigin() {
        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: originStation.locationCoordinate,
                distance: 2000000,
                heading: 0,
                pitch: 0
            )
        )
    }

    private func startTrainAnimation() {
        withAnimation(
            .linear(duration: 8)
            .repeatForever(autoreverses: true)
        ) {
            trainProgress = 1.0
        }
    }

    private func interpolatedPosition(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, progress: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: from.latitude + (to.latitude - from.latitude) * progress,
            longitude: from.longitude + (to.longitude - from.longitude) * progress
        )
    }

    private func railLineColor(_ line: String) -> String {
        switch line {
        case "TGV": return "FFCD00"
        case "ICE": return "EC0016"
        case "Eurostar": return "FFCD00"
        case "AVE": return "6B2C91"
        case "Frecciarossa": return "C8102E"
        case "Thalys": return "9B2335"
        default: return "FFCD00"
        }
    }

    private var durationOffset: CGFloat {
        let progress = CGFloat(selectedDuration - 25) / CGFloat(90 - 25)
        return (progress - 0.5) * 200
    }

    private var timelineMarks: [TimelineMark] {
        var marks: [TimelineMark] = []
        for i in stride(from: 25, through: 90, by: 5) {
            marks.append(TimelineMark(minutes: i, isMajor: [25, 45, 60, 90].contains(i)))
        }
        return marks
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(minutes)m"
    }

    private func durationFromProgress(_ progress: Double) -> Int {
        let clamped = max(0, min(1, progress))
        let duration = 25 + Int(clamped * 65)
        // Snap to nearest 5
        return (duration / 5) * 5
    }
}

// MARK: - Timeline Mark

private struct TimelineMark: Hashable {
    let minutes: Int
    let isMajor: Bool
}

// MARK: - Origin Station Marker

struct OriginStationMarker: View {
    let station: Station

    var body: some View {
        VStack(spacing: 4) {
            // Station badge
            HStack(spacing: 4) {
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 10))
                Text(station.code)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(hex: "FFCD00") ?? .yellow)
            )

            // Connector dot
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "FFCD00") ?? .yellow, lineWidth: 3)
                )
        }
    }
}

// MARK: - Destination Station Marker

struct DestinationStationMarker: View {
    let station: Station
    let travelTime: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Station badge
                HStack(spacing: 4) {
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 10))
                    Text(station.code)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color(hex: "FFCD00")?.opacity(0.9) ?? .yellow)
                )

                // Connection indicator
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.rfElectricBlue, lineWidth: 3)
                        )
                }
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Animated Train Marker

struct AnimatedTrainMarker: View {
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 24, height: 24)
                .blur(radius: 4)
                .scaleEffect(isGlowing ? 1.3 : 1.0)

            // Train dot
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .shadow(color: .white.opacity(0.5), radius: 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Destination Card

struct DestinationCard: View {
    let station: Station
    let connection: RailConnection
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Station badge
                HStack(spacing: 4) {
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 10))
                    Text(station.code)
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(hex: railLineColor) ?? .yellow)
                )

                // City name
                Text(station.city)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                // Travel time
                Text(connection.formattedTime)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .frame(width: 130)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var railLineColor: String {
        switch connection.railLine {
        case "TGV": return "FFCD00"
        case "ICE": return "EC0016"
        case "Eurostar": return "FFCD00"
        case "AVE": return "6B2C91"
        case "Frecciarossa": return "C8102E"
        case "Thalys": return "9B2335"
        default: return "FFCD00"
        }
    }
}

// MARK: - Home Station Picker (First Time Setup)

struct HomeStationPickerView: View {
    @Environment(\.appState) private var appState
    let onComplete: (Station) -> Void

    @State private var selectedStation: Station?
    @State private var searchText = ""

    private var filteredStations: [Station] {
        if searchText.isEmpty {
            return Station.europeStations.sorted { $0.city < $1.city }
        }
        return Station.europeStations.filter {
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.city < $1.city }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "train.side.front.car")
                            .font(.system(size: 48))
                            .foregroundStyle(.rfElectricBlue)

                        Text("Choose Your Home Station")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Select the station you'll most often depart from")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    // Station list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredStations) { station in
                                HomeStationRow(
                                    station: station,
                                    isSelected: selectedStation?.id == station.id
                                ) {
                                    selectedStation = station
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Continue button
                    Button {
                        if let station = selectedStation {
                            onComplete(station)
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(selectedStation != nil ? .black : Color.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Capsule()
                                    .fill(selectedStation != nil ? Color.white : Color.white.opacity(0.1))
                            )
                    }
                    .disabled(selectedStation == nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .searchable(text: $searchText, prompt: "Search stations...")
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Home Station Row

private struct HomeStationRow: View {
    let station: Station
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flag and code
                HStack(spacing: 8) {
                    Text(station.countryFlag)
                        .font(.system(size: 24))

                    Text(station.code)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(isSelected ? .black : .white)
                        .frame(width: 50)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                        )
                }

                // Station info
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.city)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(station.name)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()

                // Rail line badge
                Text(station.railLine)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.rfElectricBlue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.rfElectricBlue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Destination Picker") {
    DestinationPickerView(
        originStation: .parisGareDeLyon
    ) { destination, connection, duration in
        print("Selected: \(destination.city), \(connection.formattedTime), \(duration)m")
    }
}

#Preview("Home Station Picker") {
    HomeStationPickerView { station in
        print("Home station: \(station.city)")
    }
}
