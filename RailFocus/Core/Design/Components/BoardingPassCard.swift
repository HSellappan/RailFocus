//
//  TrainTicketCard.swift
//  RailFocus
//
//  Train ticket style card component
//

import SwiftUI

struct TrainTicketCard: View {
    let origin: String
    let originCity: String
    let destination: String
    let destinationCity: String
    let duration: String
    let date: String
    var departureTime: String = "Now"
    var arrivalTime: String?
    var carSeat: String?
    var distance: String?
    var trainName: String?
    var railLine: String?
    var hasArrived: Bool = false
    var showBarcode: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(spacing: 16) {
                // Header with rail line and status
                HStack {
                    if let railLine = railLine {
                        Text(railLine)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }

                    Spacer()

                    if hasArrived {
                        Text("ARRIVED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.rfSuccess)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.rfSuccess.opacity(0.15))
                            )
                    }
                }

                // Route display
                HStack(alignment: .center) {
                    // Origin
                    VStack(alignment: .leading, spacing: 2) {
                        Text(origin)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                        Text(originCity)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }

                    Spacer()

                    // Train icon and duration
                    VStack(spacing: 4) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.black.opacity(0.4))
                        Text(duration)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }

                    Spacer()

                    // Destination
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(destination)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                        Text(destinationCity)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                }

                // Details row
                if showBarcode {
                    HStack {
                        // Car/Seat
                        if let carSeat = carSeat {
                            TicketDetailColumn(label: "Car/Seat", value: carSeat)
                        }

                        Spacer()

                        // Distance
                        if let distance = distance {
                            TicketDetailColumn(label: "Distance", value: distance)
                        }

                        Spacer()

                        // Departure
                        TicketDetailColumn(label: "Departure", value: departureTime)

                        Spacer()

                        // Date
                        TicketDetailColumn(label: "Date", value: date)
                    }
                } else {
                    // Simplified details for background card
                    HStack {
                        TicketDetailColumn(label: "Departure", value: departureTime)
                        Spacer()
                        if let arrivalTime = arrivalTime {
                            TicketDetailColumn(label: "Arrival", value: arrivalTime)
                        }
                    }
                }

                // Train name
                if let trainName = trainName {
                    HStack {
                        Image(systemName: "train.side.front.car")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.black.opacity(0.4))
                        Text(trainName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.6))
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(Color.rfBoardingPassBg)

            // Barcode section
            if showBarcode {
                // Perforated line
                HStack(spacing: 4) {
                    ForEach(0..<40, id: \.self) { _ in
                        Circle()
                            .fill(Color.black)
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.rfBoardingPassBg)

                // Barcode
                VStack(spacing: 8) {
                    // Simple barcode representation
                    HStack(spacing: 1) {
                        ForEach(0..<30, id: \.self) { i in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: i % 3 == 0 ? 3 : 2, height: 40)
                        }
                    }

                    // QR code placeholder
                    HStack(spacing: 2) {
                        ForEach(0..<8, id: \.self) { row in
                            VStack(spacing: 2) {
                                ForEach(0..<8, id: \.self) { col in
                                    Rectangle()
                                        .fill((row + col) % 2 == 0 ? Color.black : Color.black.opacity(0.3))
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.rfBoardingPassBg)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Ticket Detail Column

private struct TicketDetailColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.black.opacity(0.4))
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
}

// MARK: - Compact Train Ticket (for lists)

struct CompactTrainTicket: View {
    let journey: Journey

    var body: some View {
        HStack(spacing: 16) {
            // Route
            VStack(alignment: .leading, spacing: 2) {
                Text(journey.routeCode)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(journey.originStation.city) → \(journey.destinationStation.city)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.6))
            }

            Spacer()

            // Duration and status
            VStack(alignment: .trailing, spacing: 2) {
                Text(journey.formattedDuration)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)

                Text(journey.status.displayText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(statusColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }

    private var statusColor: Color {
        switch journey.status {
        case .completed: return .rfSuccess
        case .inProgress: return .rfElectricBlue
        case .interrupted: return .rfWarning
        default: return .white.opacity(0.5)
        }
    }
}

// MARK: - Legacy alias for compatibility
typealias BoardingPassCard = TrainTicketCard
typealias CompactBoardingPass = CompactTrainTicket

// MARK: - Preview

#Preview("Train Ticket") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            TrainTicketCard(
                origin: "TYO",
                originCity: "Tokyo",
                destination: "OSA",
                destinationCity: "Osaka",
                duration: "2h 15m",
                date: "2026/01/03",
                carSeat: "Car 5, Seat 12",
                distance: "515 km",
                trainName: "Nozomi 225",
                railLine: "Shinkansen",
                showBarcode: true
            )
            .padding()
        }
    }
}
