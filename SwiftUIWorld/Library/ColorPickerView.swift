//
//  ColorPickerView.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 29/05/2026.
//

import SwiftUI

struct ColorPickerView: View {
    @State private var color: Color = .blue
    @State private var supportsOpacity = true

    var body: some View {
        Form {
            Section("Pick a color") {
                ColorPicker("Selection", selection: $color, supportsOpacity: supportsOpacity)
                Toggle("Supports opacity", isOn: $supportsOpacity)
            }

            Section("Preview") {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
                    .frame(height: 120)
                    .overlay {
                        Text("Sample")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle("Color Picker")
    }
}

#Preview {
    NavigationStack {
        ColorPickerView()
    }
}
