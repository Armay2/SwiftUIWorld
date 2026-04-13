//
//  RangeSlider.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 13/04/2026.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var value: Double

    var body: some View {

    }
}

struct RangeSliderPlayground: View {
    @State private var value: Double = 0.5

    var body: some View {
        VStack {
            Slider(value: $value, in: 0...100) {
                Text("here")
            } minimumValueLabel: {
                Text("minimumValueLabel")
            } maximumValueLabel: {
                Text("maximumValueLabel")
            } onEditingChanged: { value in
                print(value)
            }

            if #available(iOS 26.0, *) {
                Slider(value: $value, in: 0.0...100.0, step: 10.0, label: {}, tick: {
                    value in
                    SliderTick(value, label: {
                        Text(String(format: "%.0f", value))
                    })
                })
            } else {
                // No
            }

            RangeSlider(value: $value)
        }
    }
}

#Preview {
    RangeSliderPlayground()
}
