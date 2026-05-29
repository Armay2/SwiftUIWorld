//
//  ToolBox.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 30/04/2026.
//

import SwiftUI
import MapKit

@available(iOS 26.0, *)
struct ToolBox: View {
    @State private var searchText: String = ""
    @State private var account: AccountType = .personal
    @State private var selectedVehicle: String = "Tesla Model 3"

    @State private var showVehicleSheet = false
    @State private var showNearbySheet = false
    @State private var showPlanSheet = false
    @State private var locateTrigger = 0

    @Namespace private var glassNamespace

    private let vehicles = [
        "Tesla Model 3",
        "Tesla Model Y",
        "Renault 5 E-Tech",
        "Peugeot e-208",
        "Hyundai Ioniq 5",
        "Volkswagen ID.3",
        "Kia EV6"
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Map()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                bottomPanel
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showVehicleSheet) {
            VehicleSheet(vehicles: vehicles, selected: $selectedVehicle)
        }
        .sheet(isPresented: $showNearbySheet) {
            NearbySheet(stations: ChargingStation.samples)
        }
        .sheet(isPresented: $showPlanSheet) {
            PlanSheet()
        }
        .sensoryFeedback(.selection, trigger: account)
        .sensoryFeedback(.selection, trigger: selectedVehicle)
        .sensoryFeedback(.impact(weight: .light), trigger: locateTrigger)
        .sensoryFeedback(trigger: showVehicleSheet) { _, shown in shown ? .impact(weight: .light) : nil }
        .sensoryFeedback(trigger: showNearbySheet) { _, shown in shown ? .impact(weight: .light) : nil }
        .sensoryFeedback(trigger: showPlanSheet) { _, shown in shown ? .impact(weight: .light) : nil }
    }

    // MARK: - Top bar

    private var topBar: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    // stations list
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)

                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    TextField("Find a station", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15))
                        .submitLabel(.search)
                }
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 44)
                .glassEffect(in: .capsule)

                Button {
                    // filters
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
            }
        }
    }

    // MARK: - Bottom panel

    private var bottomPanel: some View {
        GlassEffectContainer(spacing: 12) {
            VStack(spacing: 12) {
                profileCard
                vehicleCard
                actionsRow
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 12) {
            // Account selector — opens a menu (Personal / Business)
            Menu {
                Picker("Account", selection: $account) {
                    ForEach(AccountType.allCases) { type in
                        Label(type.rawValue, systemImage: type.icon).tag(type)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: account.icon)
                        .font(.system(size: 22))
                    Text(account.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 56)
                .contentShape(Rectangle())
            }
            .tint(.primary)
            .glassEffect(in: .capsule)
            .glassEffectID("profile", in: glassNamespace)

            Spacer(minLength: 0)

            // Location — separate glass container
            Button {
                locateTrigger += 1
                // use my location
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.toolboxAccent)
                    .frame(width: 56, height: 56)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            .glassEffectID("location", in: glassNamespace)
        }
    }

    private var vehicleCard: some View {
        Button {
            showVehicleSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bolt.car.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.toolboxAccent)
                Text(selectedVehicle)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .glassEffectID("vehicle", in: glassNamespace)
    }

    private var actionsRow: some View {
        HStack(spacing: 8) {
            Button {
                showPlanSheet = true
            } label: {
                Label("Plan", systemImage: "map")
                    .fontWeight(.semibold)
                    .foregroundStyle(.toolboxAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white, in: .capsule)
                    .contentShape(.capsule)
            }
            .buttonStyle(.plain)

            Button {
                showNearbySheet = true
            } label: {
                Label("Nearby", systemImage: "location.circle")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.toolboxAccent, in: .capsule)
                    .contentShape(.capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .glassEffect(in: .capsule)
        .glassEffectID("actions", in: glassNamespace)
    }
}

// MARK: - Account

private enum AccountType: String, CaseIterable, Identifiable {
    case personal = "Personal"
    case business = "Business"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .personal: "person.crop.circle.fill"
        case .business: "briefcase.fill"
        }
    }
}

// MARK: - Charging station model

private struct ChargingStation: Identifiable {
    let id = UUID()
    let name: String
    let distance: String
    let available: Int
    let total: Int
    let power: String

    static let samples: [ChargingStation] = [
        .init(name: "Electra - Gare de Lyon", distance: "0.3 km", available: 4, total: 6, power: "300 kW"),
        .init(name: "Electra - Bastille", distance: "0.8 km", available: 2, total: 4, power: "225 kW"),
        .init(name: "Electra - République", distance: "1.2 km", available: 6, total: 8, power: "300 kW"),
        .init(name: "Electra - Nation", distance: "1.6 km", available: 0, total: 4, power: "150 kW"),
        .init(name: "Electra - Père Lachaise", distance: "2.1 km", available: 3, total: 6, power: "300 kW")
    ]
}

// MARK: - Accent color

private extension ShapeStyle where Self == Color {
    /// ToolBox screen accent (#127882) — used in place of the usual green, on this screen only.
    static var toolboxAccent: Color {
        Color(red: 18 / 255, green: 120 / 255, blue: 130 / 255)
    }
}

// MARK: - Sheets

@available(iOS 26.0, *)
private struct VehicleSheet: View {
    let vehicles: [String]
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(vehicles, id: \.self) { vehicle in
                Button {
                    selected = vehicle
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.car.fill")
                            .foregroundStyle(.toolboxAccent)
                        Text(vehicle)
                        Spacer()
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.toolboxAccent)
                            .opacity(vehicle == selected ? 1 : 0)
                    }
                }
                .tint(.primary)
            }
            .navigationTitle("Your vehicle")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

@available(iOS 26.0, *)
private struct NearbySheet: View {
    let stations: [ChargingStation]

    var body: some View {
        NavigationStack {
            List(stations) { station in
                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(station.available > 0 ? Color.toolboxAccent : Color.gray, in: .circle)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.name)
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(station.available)/\(station.total) available · \(station.power)")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(station.distance)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Nearby stations")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

@available(iOS 26.0, *)
private struct PlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var origin = ""
    @State private var destination = ""
    @State private var planTrigger = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    LabeledContent("From") {
                        TextField("Current location", text: $origin)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("To") {
                        TextField("Destination", text: $destination)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Button {
                        planTrigger += 1
                        dismiss()
                    } label: {
                        Text("Plan route")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.toolboxAccent)
                }
            }
            .navigationTitle("Plan a route")
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(.success, trigger: planTrigger)
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        if #available(iOS 26.0, *) {
            ToolBox()
        } else {
            Text("Only iOS 26+")
        }
    }
}

#Preview("Vehicle sheet") {
    if #available(iOS 26.0, *) {
        VehicleSheet(
            vehicles: ["Tesla Model 3", "Tesla Model Y", "Renault 5 E-Tech", "Peugeot e-208"],
            selected: .constant("Tesla Model 3")
        )
    }
}

#Preview("Nearby sheet") {
    if #available(iOS 26.0, *) {
        NearbySheet(stations: ChargingStation.samples)
    }
}

#Preview("Plan sheet") {
    if #available(iOS 26.0, *) {
        PlanSheet()
    }
}
