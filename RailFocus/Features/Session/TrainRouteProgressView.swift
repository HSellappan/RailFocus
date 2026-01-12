//
//  TrainRouteProgressView.swift
//  RailFocus
//
//  Visual route progress with animated train icon moving along track.
//  Shows stations as milestones, with passed stations dimmed.
//

import SwiftUI

// MARK: - Train Route Progress View

struct TrainRouteProgressView: View {
    let progress: Double // 0.0 to 1.0
    let stations: [StationMilestone]
    let originName: String
    let destinationName: String
    let isVertical: Bool

    @State private var trainPulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        progress: Double,
        stations: [StationMilestone],
        originName: String,
        destinationName: String,
        isVertical: Bool = true
    ) {
        self.progress = progress
        self.stations = stations
        self.originName = originName
        self.destinationName = destinationName
        self.isVertical = isVertical
    }

    var body: some View {
        if isVertical {
            verticalRouteView
        } else {
            horizontalRouteView
        }
    }

    // MARK: - Vertical Route View

    private var verticalRouteView: some View {
        GeometryReader { geometry in
            let trackHeight = geometry.size.height - 60
            let trackTop: CGFloat = 30
            let trackX = geometry.size.width / 2

            ZStack {
                // Track line (background)
                trackLine(
                    from: CGPoint(x: trackX, y: trackTop),
                    to: CGPoint(x: trackX, y: trackTop + trackHeight),
                    isBackground: true
                )

                // Track line (progress)
                trackLine(
                    from: CGPoint(x: trackX, y: trackTop),
                    to: CGPoint(x: trackX, y: trackTop + trackHeight * progress),
                    isBackground: false
                )

                // Station nodes
                ForEach(stations) { station in
                    let y = trackTop + trackHeight * station.progressPosition

                    StationNode(
                        station: station,
                        isOrigin: station.progressPosition == 0,
                        isDestination: station.progressPosition == 1
                    )
                    .position(x: trackX, y: y)

                    // Station label
                    if station.progressPosition == 0 || station.progressPosition == 1 {
                        Text(station.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(station.isPassed ? Color.white.opacity(0.5) : .white)
                            .position(x: trackX + 50, y: y)
                    }
                }

                // Train icon
                trainIcon
                    .position(
                        x: trackX,
                        y: trackTop + trackHeight * min(progress, 0.98)
                    )
            }
        }
    }

    // MARK: - Horizontal Route View

    private var horizontalRouteView: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - 80
            let trackLeft: CGFloat = 40
            let trackY = geometry.size.height / 2

            ZStack {
                // Track line (background)
                trackLine(
                    from: CGPoint(x: trackLeft, y: trackY),
                    to: CGPoint(x: trackLeft + trackWidth, y: trackY),
                    isBackground: true
                )

                // Track line (progress)
                trackLine(
                    from: CGPoint(x: trackLeft, y: trackY),
                    to: CGPoint(x: trackLeft + trackWidth * progress, y: trackY),
                    isBackground: false
                )

                // Station nodes
                ForEach(stations) { station in
                    let x = trackLeft + trackWidth * station.progressPosition

                    VStack(spacing: 8) {
                        StationNode(
                            station: station,
                            isOrigin: station.progressPosition == 0,
                            isDestination: station.progressPosition == 1
                        )

                        if station.progressPosition == 0 || station.progressPosition == 1 {
                            Text(station.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(station.isPassed ? Color.white.opacity(0.5) : .white)
                                .lineLimit(1)
                        }
                    }
                    .position(x: x, y: trackY + 25)
                }

                // Train icon
                trainIcon
                    .rotationEffect(.degrees(-90))
                    .position(
                        x: trackLeft + trackWidth * min(progress, 0.98),
                        y: trackY - 20
                    )
            }
        }
    }

    // MARK: - Track Line

    @ViewBuilder
    private func trackLine(from start: CGPoint, to end: CGPoint, isBackground: Bool) -> some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(
            isBackground ? Color.white.opacity(0.15) : Color.white.opacity(0.6),
            style: StrokeStyle(
                lineWidth: isBackground ? 3 : 3,
                lineCap: .round,
                dash: isBackground ? [6, 4] : []
            )
        )
    }

    // MARK: - Train Icon

    private var trainIcon: some View {
        ZStack {
            // Glow effect
            if !reduceMotion {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                    .scaleEffect(trainPulse ? 1.2 : 1.0)
            }

            // Train body
            Image(systemName: "train.side.front.car")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    trainPulse = true
                }
            }
        }
    }
}

// MARK: - Station Node

struct StationNode: View {
    let station: StationMilestone
    let isOrigin: Bool
    let isDestination: Bool

    @State private var pulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var nodeSize: CGFloat {
        if isOrigin || isDestination { return 16 }
        return 10
    }

    var body: some View {
        ZStack {
            // Pulse ring for next station
            if !station.isPassed && !reduceMotion {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: nodeSize + 8, height: nodeSize + 8)
                    .scaleEffect(pulsing ? 1.3 : 1.0)
                    .opacity(pulsing ? 0 : 0.5)
            }

            // Main node
            Circle()
                .fill(station.isPassed ? Color.white : Color.white.opacity(0.3))
                .frame(width: nodeSize, height: nodeSize)

            // Border for destination
            if isDestination {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: nodeSize, height: nodeSize)
            }
        }
        .onAppear {
            if !station.isPassed && !reduceMotion {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    pulsing = true
                }
            }
        }
    }
}

// MARK: - Compact Route Header

struct CompactRouteHeader: View {
    let originCode: String
    let destinationCode: String
    let progress: Double

    var body: some View {
        HStack(spacing: 12) {
            // Origin
            Text(originCode)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)

            // Progress indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    // Progress fill
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress, height: 4)

                    // Train dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .offset(x: geometry.size.width * progress - 4)
                }
            }
            .frame(height: 8)

            // Destination
            Text(destinationCode)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Mini Route Display

struct MiniRouteDisplay: View {
    let stations: [StationMilestone]
    let progress: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
                // Station dot
                Circle()
                    .fill(station.isPassed ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)

                // Connector line (except after last station)
                if index < stations.count - 1 {
                    Rectangle()
                        .fill(station.isPassed ? Color.white.opacity(0.5) : Color.white.opacity(0.15))
                        .frame(height: 2)
                        .frame(maxWidth: 20)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Vertical") {
    ZStack {
        Color.black.ignoresSafeArea()

        TrainRouteProgressView(
            progress: 0.45,
            stations: [
                StationMilestone(name: "Paris", progressPosition: 0.0, isPassed: true),
                StationMilestone(name: "Dijon", progressPosition: 0.25, isPassed: true),
                StationMilestone(name: "Macon", progressPosition: 0.5, isPassed: false),
                StationMilestone(name: "Lyon", progressPosition: 1.0, isPassed: false)
            ],
            originName: "Paris",
            destinationName: "Lyon",
            isVertical: true
        )
        .frame(width: 200, height: 400)
    }
}

#Preview("Horizontal") {
    ZStack {
        Color.black.ignoresSafeArea()

        TrainRouteProgressView(
            progress: 0.6,
            stations: [
                StationMilestone(name: "PAR", progressPosition: 0.0, isPassed: true),
                StationMilestone(name: "DIJ", progressPosition: 0.33, isPassed: true),
                StationMilestone(name: "MAC", progressPosition: 0.66, isPassed: false),
                StationMilestone(name: "LYO", progressPosition: 1.0, isPassed: false)
            ],
            originName: "Paris",
            destinationName: "Lyon",
            isVertical: false
        )
        .frame(height: 100)
        .padding()
    }
}

#Preview("Compact Header") {
    ZStack {
        Color.black.ignoresSafeArea()

        CompactRouteHeader(
            originCode: "PAR",
            destinationCode: "LYO",
            progress: 0.45
        )
        .padding()
    }
}
