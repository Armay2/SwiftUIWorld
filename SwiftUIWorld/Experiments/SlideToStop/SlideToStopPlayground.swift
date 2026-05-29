//
//  SlideToStopPlayground.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 29/05/2026.
//

import SwiftUI

struct SlideToStopPlayground: View {
    @State private var phase: SlideToStopPhase = .idle
    @State private var shouldFail = false
    @State private var disabledPhase: SlideToStopPhase = .idle

    var body: some View {
        VStack(spacing: 32) {
            sessionCard

            Toggle("Simulate failure", isOn: $shouldFail)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Disabled").font(.headline)
                SlideToStop(phase: $disabledPhase).disabled(true)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("Slide to Stop")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: phase) {
            guard phase == .loading else { return }
            try? await Task.sleep(for: .seconds(2))   // simulate the network stop
            phase = shouldFail ? .failure : .success
        }
    }

    private var sessionCard: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "bolt.car.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Charging").font(.headline)
                    Text(statusText).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Text("32 kW").font(.title3.monospacedDigit().bold())
            }
            SlideToStop(phase: $phase)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal)
    }

    private var statusText: String {
        switch phase {
        case .idle:    return "Session active"
        case .loading: return "Stopping…"
        case .success: return "Charge stopped"
        case .failure: return "Couldn't stop — try again"
        }
    }
}

#Preview {
    NavigationStack { SlideToStopPlayground() }
}
