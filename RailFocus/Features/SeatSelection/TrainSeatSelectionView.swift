//
//  TrainSeatSelectionView.swift
//  RailFocus
//
//  Train car outline with seat selection and focus task picker
//

import SwiftUI

struct TrainSeatSelectionView: View {
    let journey: Journey
    let onComplete: (String, FocusTag?) -> Void // seat, focusTag

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSeat: String?
    @State private var selectedTask: FocusTag?
    @State private var showTaskPicker = false

    // Seat configuration: 2+2 (A,C - D,F)
    private let columns = ["A", "C", "D", "F"]
    private let rows = 12

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Subtle map background
            StarsBackgroundView()
                .opacity(0.15)

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                Spacer()

                // Train car with seats
                trainCarView
                    .padding(.horizontal, 40)

                Spacer()

                // Task picker (appears when seat selected)
                if showTaskPicker {
                    taskPickerCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showTaskPicker)
        .animation(.spring(response: 0.3), value: selectedSeat)
    }

    // MARK: - Header

    private var header: some View {
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

            VStack(spacing: 4) {
                Text("Select Your Seat")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text("\(journey.originStation.code) → \(journey.destinationStation.code)")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Spacer()

            // Placeholder for balance
            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    // MARK: - Train Car View

    private var trainCarView: some View {
        GeometryReader { geometry in
            let carWidth = min(geometry.size.width, 280)
            let carHeight = geometry.size.height

            ZStack {
                // Train body outline
                TrainCarShape()
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        TrainCarShape()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    )

                VStack(spacing: 0) {
                    // Front windows
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 60, height: 40)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 60, height: 40)
                    }
                    .padding(.top, carHeight * 0.12)

                    Spacer()
                        .frame(height: 30)

                    // Column headers
                    HStack(spacing: 0) {
                        ForEach(columns, id: \.self) { col in
                            Text(col)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.4))
                                .frame(maxWidth: .infinity)

                            if col == "C" {
                                Spacer()
                                    .frame(width: 40)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Seats grid
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(1...rows, id: \.self) { row in
                                seatRow(row: row)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, carHeight * 0.08)
                }
            }
            .frame(width: carWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Seat Row

    private func seatRow(row: Int) -> some View {
        HStack(spacing: 0) {
            // Left seats (A, C)
            ForEach(["A", "C"], id: \.self) { col in
                seatButton(row: row, col: col)
            }

            // Aisle with row number
            Text(String(format: "%02d", row))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.3))
                .frame(width: 40)

            // Right seats (D, F)
            ForEach(["D", "F"], id: \.self) { col in
                seatButton(row: row, col: col)
            }
        }
    }

    // MARK: - Seat Button

    @ViewBuilder
    private func seatButton(row: Int, col: String) -> some View {
        let seatId = String(format: "%02d%@", row, col)
        let isSelected = selectedSeat == seatId
        let isOccupied = occupiedSeats.contains(seatId)

        Button {
            if !isOccupied {
                selectedSeat = seatId
                showTaskPicker = true
            }
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    isSelected ? Color.white :
                    isOccupied ? Color.white.opacity(0.03) :
                    Color.white.opacity(0.08)
                )
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isSelected ? Color.white : Color.white.opacity(0.1),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isOccupied)
    }

    // Simulated occupied seats
    private var occupiedSeats: Set<String> {
        ["03A", "05C", "07D", "08F", "10A", "10C", "11D"]
    }

    // MARK: - Task Picker Card

    private var taskPickerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Seat info
            if let seat = selectedSeat {
                Text("Seat: \(seat)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Text("What do you want to focus on?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            // Task options using FocusTag directly
            FlowLayout(spacing: 10) {
                ForEach(FocusTag.allCases) { tag in
                    FocusTagChip(
                        tag: tag,
                        isSelected: selectedTask == tag
                    ) {
                        selectedTask = tag
                    }
                }

                // Add custom button
                Button {
                    // Show custom task input
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }

            // Continue button
            Button {
                if let seat = selectedSeat {
                    onComplete(seat, selectedTask)
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(selectedTask != nil ? .black : Color.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(selectedTask != nil ? Color.white : Color.white.opacity(0.1))
                    )
            }
            .disabled(selectedTask == nil)
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                )
        )
    }
}

// MARK: - Focus Tag Chip (uses FocusTag directly)

struct FocusTagChip: View {
    let tag: FocusTag
    let isSelected: Bool
    let action: () -> Void

    private var tagColor: Color {
        switch tag {
        case .work: return Color(hex: "9B7ED9") ?? .purple
        case .study: return Color(hex: "7DD3A8") ?? .green
        case .coding: return Color(hex: "64B5F6") ?? .blue
        case .writing: return Color(hex: "D4A574") ?? .orange
        case .admin: return Color(hex: "C490D1") ?? .pink
        case .personal: return Color(hex: "7DD3C0") ?? .teal
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tag.icon)
                    .font(.system(size: 14))
                Text(tag.displayName)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(tagColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(tagColor.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? tagColor : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Train Car Shape

struct TrainCarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let noseHeight = height * 0.15
        let cornerRadius: CGFloat = 20

        // Start at bottom left
        path.move(to: CGPoint(x: cornerRadius, y: height))

        // Bottom edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: height))

        // Bottom right corner
        path.addQuadCurve(
            to: CGPoint(x: width, y: height - cornerRadius),
            control: CGPoint(x: width, y: height)
        )

        // Right edge
        path.addLine(to: CGPoint(x: width, y: noseHeight + cornerRadius))

        // Top right corner curving into nose
        path.addQuadCurve(
            to: CGPoint(x: width - cornerRadius, y: noseHeight),
            control: CGPoint(x: width, y: noseHeight)
        )

        // Right side of nose curve
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control: CGPoint(x: width * 0.7, y: noseHeight * 0.3)
        )

        // Left side of nose curve
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: noseHeight),
            control: CGPoint(x: width * 0.3, y: noseHeight * 0.3)
        )

        // Top left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: noseHeight + cornerRadius),
            control: CGPoint(x: 0, y: noseHeight)
        )

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: height - cornerRadius))

        // Bottom left corner
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: height),
            control: CGPoint(x: 0, y: height)
        )

        return path
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    TrainSeatSelectionView(
        journey: Journey(
            origin: .parisGareDeLyon,
            destination: .lyonPartDieu,
            duration: 25 * 60
        )
    ) { seat, task in
        print("Selected seat: \(seat), task: \(task?.rawValue ?? "none")")
    }
}
