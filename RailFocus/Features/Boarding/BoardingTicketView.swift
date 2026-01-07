//
//  BoardingTicketView.swift
//  RailFocus
//
//  Interactive train ticket with tear-off barcode for boarding
//

import SwiftUI
import UIKit

struct BoardingTicketView: View {
    let journey: Journey
    let onBoard: () -> Void

    @State private var tearOffset: CGFloat = 0
    @State private var isTorn = false
    @State private var showBoardingButton = false
    @Environment(\.dismiss) private var dismiss

    private let tearThreshold: CGFloat = 120

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Main ticket
                VStack(spacing: 0) {
                    // Ticket body
                    ticketBody

                    // Perforation line
                    if !isTorn {
                        perforationLine
                    }

                    // Tearable barcode section
                    if !isTorn {
                        barcodeSection
                            .offset(x: tearOffset)
                            .gesture(tearGesture)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Instructions or boarding button
                if isTorn {
                    Button {
                        onBoard()
                    } label: {
                        Text("Board Train")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Text("Swipe barcode to tear off and board")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .padding(.bottom, 40)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTorn)
    }

    // MARK: - Ticket Body

    private var ticketBody: some View {
        VStack(spacing: 0) {
            // World map background with content
            ZStack {
                // Dotted world map background
                WorldMapDotsView()
                    .opacity(0.15)

                VStack(spacing: 20) {
                    // Route display
                    HStack(alignment: .center) {
                        // Origin
                        VStack(alignment: .leading, spacing: 4) {
                            Text(journey.originStation.code)
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(journey.originStation.city)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }

                        Spacer()

                        // Train icon and duration
                        VStack(spacing: 6) {
                            Image(systemName: "train.side.front.car")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.white.opacity(0.5))
                            Text(journey.formattedDuration)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }

                        Spacer()

                        // Destination
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(journey.destinationStation.code)
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(journey.destinationStation.city)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }

                    // Details grid
                    HStack {
                        TicketDetail(label: "Seat", value: generateSeat())
                        Spacer()
                        TicketDetail(label: "Distance", value: String(format: "%.0f mi", journey.distanceMiles))
                        Spacer()
                        TicketDetail(label: "Boarding", value: "Now")
                        Spacer()
                        TicketDetail(label: "Date", value: formattedDate)
                    }

                    // Train mode row
                    HStack {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.orange)
                        Text("Train Mode")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.7))
                        Spacer()
                        Text("Not set")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white.opacity(0.4))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(white: 0.15))
            )
            .clipShape(
                TicketTopShape()
            )
        }
    }

    // MARK: - Perforation Line

    private var perforationLine: some View {
        HStack(spacing: 6) {
            ForEach(0..<30, id: \.self) { _ in
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 8, height: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .background(Color(white: 0.15))
    }

    // MARK: - Barcode Section

    private var barcodeSection: some View {
        VStack(spacing: 12) {
            // Barcode
            HStack(spacing: 2) {
                ForEach(0..<35, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: barcodeWidth(for: i), height: 50)
                }
            }

            Text("Boarding")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            TicketBottomShape()
                .fill(Color(white: 0.15))
        )
    }

    // MARK: - Tear Gesture

    private var tearGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                tearOffset = value.translation.width
            }
            .onEnded { value in
                if abs(value.translation.width) > tearThreshold {
                    // Tear successful
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        tearOffset = value.translation.width > 0 ? 400 : -400
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            isTorn = true
                        }
                    }

                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    // Spring back
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        tearOffset = 0
                    }
                }
            }
    }

    // MARK: - Helpers

    private func barcodeWidth(for index: Int) -> CGFloat {
        // Generate pseudo-random widths for barcode appearance
        let widths: [CGFloat] = [2, 3, 2, 4, 2, 3, 2, 2, 4, 3, 2, 4, 2, 3, 3, 2, 4, 2, 3, 2, 4, 2, 2, 3, 4, 2, 3, 2, 4, 2, 3, 2, 2, 4, 3]
        return widths[index % widths.count]
    }

    private func generateSeat() -> String {
        let car = Int.random(in: 1...8)
        let seat = String(format: "%02d", Int.random(in: 1...60))
        let letter = ["A", "B", "C", "D"].randomElement()!
        return "\(car)-\(seat)\(letter)"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Ticket Detail

private struct TicketDetail: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.4))
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - World Map Dots View

struct WorldMapDotsView: View {
    var body: some View {
        Canvas { context, size in
            // Generate dots to create a world map-like pattern
            let dotSize: CGFloat = 2
            let spacing: CGFloat = 8

            for x in stride(from: 0, to: size.width, by: spacing) {
                for y in stride(from: 0, to: size.height, by: spacing) {
                    // Use noise-like function to create landmass shapes
                    let noise = worldMapNoise(x: x / size.width, y: y / size.height)
                    if noise > 0.5 {
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                        context.fill(Circle().path(in: rect), with: .color(.white))
                    }
                }
            }
        }
    }

    private func worldMapNoise(x: Double, y: Double) -> Double {
        // Simple noise function to create continent-like shapes
        let val = sin(x * 12) * cos(y * 8) + sin(x * 5 + y * 7) * 0.5
        return (val + 1) / 2
    }
}

// MARK: - Custom Shapes

struct TicketTopShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchRadius: CGFloat = 12

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))

        // Right notch
        path.addArc(
            center: CGPoint(x: rect.width, y: rect.height),
            radius: notchRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: 0, y: rect.height))

        // Left notch
        path.addArc(
            center: CGPoint(x: 0, y: rect.height),
            radius: notchRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )

        path.closeSubpath()
        return path
    }
}

struct TicketBottomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchRadius: CGFloat = 12
        let cornerRadius: CGFloat = 16

        // Start from top-left, account for notch
        path.move(to: CGPoint(x: notchRadius, y: 0))

        // Top edge with notches
        path.addArc(
            center: CGPoint(x: 0, y: 0),
            radius: notchRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(-90),
            clockwise: true
        )

        path.move(to: CGPoint(x: notchRadius, y: 0))
        path.addLine(to: CGPoint(x: rect.width - notchRadius, y: 0))

        path.addArc(
            center: CGPoint(x: rect.width, y: 0),
            radius: notchRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: true
        )

        // Right edge and bottom-right corner
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - cornerRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))

        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - cornerRadius),
            control: CGPoint(x: 0, y: rect.height)
        )

        // Left edge back to start
        path.addLine(to: CGPoint(x: 0, y: notchRadius))

        return path
    }
}

// MARK: - Preview

#Preview {
    BoardingTicketView(
        journey: Journey(
            origin: .tokyo,
            destination: .osaka,
            duration: 90 * 60
        )
    ) {
        print("Boarding!")
    }
}
