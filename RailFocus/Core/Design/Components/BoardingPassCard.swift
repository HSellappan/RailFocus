//
//  BoardingPassCard.swift
//  RailFocus
//
//  Boarding pass style card component
//

import SwiftUI

struct BoardingPassCard: View {
    let origin: String
    let originCity: String
    let destination: String
    let destinationCity: String
    let duration: String
    let date: String
    var departureTime: String = "Now"
    var arrivalTime: String?
    var seat: String?
    var distance: String?
    var isLanded: Bool = false
    var showBarcode: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(spacing: 16) {
                // Header with date and status
                HStack {
                    if !showBarcode {
                        Text(date)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }

                    Spacer()

                    if isLanded {
                        Text("LANDED")
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

                    // Flight icon and duration
                    VStack(spacing: 4) {
                        Image(systemName: "airplane")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.black.opacity(0.4))
                            .rotationEffect(.degrees(90))
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
                        // Seat
                        if let seat = seat {
                            DetailColumn(label: "Seat", value: seat)
                        }

                        Spacer()

                        // Distance
                        if let distance = distance {
                            DetailColumn(label: "Distance", value: distance)
                        }

                        Spacer()

                        // Boarding/Departure
                        DetailColumn(label: "Boarding", value: departureTime)

                        Spacer()

                        // Date
                        DetailColumn(label: "Date", value: date)
                    }
                } else {
                    // Simplified details for background card
                    HStack {
                        DetailColumn(label: "Departure", value: departureTime)
                        Spacer()
                        if let arrivalTime = arrivalTime {
                            DetailColumn(label: "Arrival", value: arrivalTime)
                        }
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

// MARK: - Detail Column

private struct DetailColumn: View {
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

// MARK: - Compact Boarding Pass (for lists)

struct CompactBoardingPass: View {
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

                if journey.status == .completed {
                    Text("LANDED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.rfSuccess)
                } else if journey.status == .inProgress {
                    Text("IN FLIGHT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.rfElectricBlue)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - Preview

#Preview("Boarding Pass") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            BoardingPassCard(
                origin: "LHR",
                originCity: "London",
                destination: "CDG",
                destinationCity: "Paris",
                duration: "42m",
                date: "2026/01/03",
                seat: "21A",
                distance: "216 mi",
                showBarcode: true
            )
            .padding()
        }
    }
}
