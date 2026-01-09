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
    let seat: String?
    let focusTag: FocusTag?
    let onBoard: () -> Void

    @State private var tearOffset: CGFloat = 0
    @State private var tearRotation: Double = 0
    @State private var isTorn = false
    @State private var showBoardingButton = false
    @State private var dragIndicatorPulse = false
    @Environment(\.dismiss) private var dismiss

    private let tearThreshold: CGFloat = 100

    init(journey: Journey, seat: String? = nil, focusTag: FocusTag? = nil, onBoard: @escaping () -> Void) {
        self.journey = journey
        self.seat = seat
        self.focusTag = focusTag
        self.onBoard = onBoard
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Subtle background
            StarsBackgroundView()
                .opacity(0.1)

            VStack(spacing: 0) {
                Spacer()

                // Main ticket
                VStack(spacing: 0) {
                    // Ticket body
                    ticketBody

                    // Perforation line with drag indicator
                    if !isTorn {
                        perforationLineWithIndicator
                    }

                    // Tearable barcode section
                    if !isTorn {
                        barcodeSection
                            .offset(x: tearOffset)
                            .rotationEffect(.degrees(tearRotation), anchor: .top)
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
                        Text("Check in")
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
                    VStack(spacing: 8) {
                        Text("Drag to tear off")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.6))

                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.4))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTorn)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                dragIndicatorPulse = true
            }
        }
    }

    // MARK: - Ticket Body

    private var ticketBody: some View {
        VStack(spacing: 0) {
            ZStack {
                // Dotted world map background
                WorldMapDotsView()
                    .opacity(0.12)

                VStack(spacing: 20) {
                    // Route display
                    HStack(alignment: .center) {
                        // Origin
                        VStack(alignment: .leading, spacing: 4) {
                            Text(journey.originStation.code)
                                .font(.system(size: 38, weight: .bold, design: .default))
                                .foregroundStyle(.white)
                            Text(journey.originStation.city)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }

                        Spacer()

                        // Train icon and duration
                        VStack(spacing: 6) {
                            Image(systemName: "train.side.front.car")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.white.opacity(0.4))
                            Text(journey.formattedDuration)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }

                        Spacer()

                        // Destination
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(journey.destinationStation.code)
                                .font(.system(size: 38, weight: .bold, design: .default))
                                .foregroundStyle(.white)
                            Text(journey.destinationStation.city)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                    }

                    // Details grid
                    HStack {
                        TicketDetail(label: "Seat", value: seat ?? generateSeat())
                        Spacer()
                        TicketDetail(label: "Distance", value: String(format: "%.0f mi", journey.distanceMiles))
                    }

                    HStack {
                        TicketDetail(label: "Boarding", value: "Now")
                        Spacer()
                        TicketDetail(label: "Date", value: formattedDate)
                    }
                }
                .padding(24)
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(white: 0.12))
            )
            .clipShape(
                TicketTopShape()
            )
        }
    }

    // MARK: - Perforation Line with Indicator

    private var perforationLineWithIndicator: some View {
        ZStack {
            // Dashed line
            HStack(spacing: 4) {
                ForEach(0..<40, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: "C4A574").opacity(0.5))
                        .frame(width: 6, height: 2)
                }
            }
            .frame(maxWidth: .infinity)

            // White circle drag indicator
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 28, height: 28)
                .scaleEffect(dragIndicatorPulse ? 1.1 : 0.9)
                .shadow(color: Color.white.opacity(0.3), radius: 8)
        }
        .frame(height: 28)
        .background(Color(white: 0.12))
    }

    // MARK: - Barcode Section

    private var barcodeSection: some View {
        VStack(spacing: 0) {
            // Barcode
            HStack(spacing: 1.5) {
                ForEach(0..<45, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: barcodeWidth(for: i), height: 60)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            TicketBottomShape()
                .fill(Color(white: 0.12))
        )
    }

    // MARK: - Tear Gesture

    private var tearGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                tearOffset = value.translation.width
                // Add rotation based on drag direction
                tearRotation = Double(value.translation.width) * 0.05
            }
            .onEnded { value in
                if abs(value.translation.width) > tearThreshold {
                    // Tear successful - animate off screen with rotation
                    withAnimation(.easeOut(duration: 0.4)) {
                        tearOffset = value.translation.width > 0 ? 500 : -500
                        tearRotation = value.translation.width > 0 ? 25 : -25
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.4)) {
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
                        tearRotation = 0
                    }
                }
            }
    }

    // MARK: - Helpers

    private func barcodeWidth(for index: Int) -> CGFloat {
        let widths: [CGFloat] = [2, 4, 2, 3, 5, 2, 4, 2, 3, 2, 5, 3, 2, 4, 2, 3, 5, 2, 4, 3, 2, 5, 2, 3, 4, 2, 5, 3, 2, 4, 2, 3, 5, 2, 4, 2, 3, 5, 2, 4, 3, 2, 5, 2, 3]
        return widths[index % widths.count]
    }

    private func generateSeat() -> String {
        let seat = String(format: "%02d", Int.random(in: 1...12))
        let letter = ["A", "C", "D", "F"].randomElement()!
        return "\(seat)\(letter)"
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
            let dotSize: CGFloat = 2
            let spacing: CGFloat = 8

            for x in stride(from: 0, to: size.width, by: spacing) {
                for y in stride(from: 0, to: size.height, by: spacing) {
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
        let val = sin(x * 12) * cos(y * 8) + sin(x * 5 + y * 7) * 0.5
        return (val + 1) / 2
    }
}

// MARK: - Custom Shapes

struct TicketTopShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchRadius: CGFloat = 14
        let cornerRadius: CGFloat = 16

        // Top left corner
        path.move(to: CGPoint(x: cornerRadius, y: 0))

        // Top edge
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))

        // Top right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cornerRadius),
            control: CGPoint(x: rect.width, y: 0)
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - notchRadius))

        // Right notch
        path.addArc(
            center: CGPoint(x: rect.width, y: rect.height),
            radius: notchRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: 0, y: rect.height + notchRadius))

        // Left notch
        path.addArc(
            center: CGPoint(x: 0, y: rect.height),
            radius: notchRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))

        // Top left corner
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        path.closeSubpath()
        return path
    }
}

struct TicketBottomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchRadius: CGFloat = 14
        let cornerRadius: CGFloat = 16

        // Start from top-left after notch
        path.move(to: CGPoint(x: 0, y: notchRadius))

        // Left notch (inverted)
        path.addArc(
            center: CGPoint(x: 0, y: 0),
            radius: notchRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )

        // Top edge
        path.addLine(to: CGPoint(x: rect.width - notchRadius, y: -notchRadius))

        // Right notch (inverted)
        path.addArc(
            center: CGPoint(x: rect.width, y: 0),
            radius: notchRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))

        // Bottom right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.width - cornerRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))

        // Bottom left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - cornerRadius),
            control: CGPoint(x: 0, y: rect.height)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    BoardingTicketView(
        journey: Journey(
            origin: .parisGareDeLyon,
            destination: .lyonPartDieu,
            duration: 30 * 60
        ),
        seat: "02F",
        focusTag: .work
    ) {
        print("Boarding!")
    }
}
