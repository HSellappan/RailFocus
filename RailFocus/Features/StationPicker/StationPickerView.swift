//
//  StationPickerView.swift
//  RailFocus
//
//  Station selection interface for European high-speed rail
//

import SwiftUI

struct StationPickerView: View {
    @Binding var selectedStation: Station
    let title: String
    let excludeStation: Station?

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCountry: String?

    private var filteredStations: [Station] {
        var stations = Station.europeStations

        // Exclude the other selected station
        if let exclude = excludeStation {
            stations = stations.filter { $0.id != exclude.id }
        }

        // Filter by country if selected
        if let country = selectedCountry {
            stations = stations.filter { $0.country == country }
        }

        // Filter by search text
        if !searchText.isEmpty {
            stations = stations.filter {
                $0.city.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.code.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText)
            }
        }

        return stations.sorted { $0.city < $1.city }
    }

    private var groupedStations: [(String, [Station])] {
        let grouped = Dictionary(grouping: filteredStations) { $0.country }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Country filter chips
                    countryFilterChips
                        .padding(.vertical, 12)

                    // Station list
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(groupedStations, id: \.0) { country, stations in
                                Section {
                                    ForEach(stations) { station in
                                        StationRow(
                                            station: station,
                                            isSelected: station.id == selectedStation.id
                                        ) {
                                            selectedStation = station
                                            dismiss()
                                        }
                                    }
                                } header: {
                                    CountrySectionHeader(country: country, flag: stations.first?.countryFlag ?? "🇪🇺")
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search stations...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Country Filter Chips

    private var countryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All countries chip
                FilterChip(
                    label: "All",
                    flag: "🇪🇺",
                    isSelected: selectedCountry == nil
                ) {
                    selectedCountry = nil
                }

                ForEach(Station.countries, id: \.self) { country in
                    let flag = Station.europeStations.first { $0.country == country }?.countryFlag ?? "🇪🇺"
                    FilterChip(
                        label: country,
                        flag: flag,
                        isSelected: selectedCountry == country
                    ) {
                        selectedCountry = selectedCountry == country ? nil : country
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let flag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(flag)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
            )
        }
    }
}

// MARK: - Country Section Header

private struct CountrySectionHeader: View {
    let country: String
    let flag: String

    var body: some View {
        HStack(spacing: 8) {
            Text(flag)
                .font(.system(size: 16))
            Text(country)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.6))
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(Color.black)
    }
}

// MARK: - Station Row

private struct StationRow: View {
    let station: Station
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Station code badge
                Text(station.code)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(isSelected ? .black : .white)
                    .frame(width: 50)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                    )

                // Station details
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.city)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(station.name)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.5))
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
                            .fill(railLineColor(station.railLine).opacity(0.3))
                    )

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.rfElectricBlue)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func railLineColor(_ line: String) -> Color {
        switch line {
        case "TGV": return Color(hex: "9B2335") ?? .red
        case "ICE": return Color(hex: "EC0016") ?? .red
        case "Eurostar": return Color(hex: "FFCD00") ?? .yellow
        case "AVE": return Color(hex: "6B2C91") ?? .purple
        case "Frecciarossa": return Color(hex: "C8102E") ?? .red
        case "Thalys": return Color(hex: "9B2335") ?? .red
        case "SBB": return Color.red
        case "ÖBB": return Color.red
        default: return .gray
        }
    }
}

// MARK: - Preview

#Preview {
    StationPickerView(
        selectedStation: .constant(.parisGareDeLyon),
        title: "Select Origin",
        excludeStation: nil
    )
}
