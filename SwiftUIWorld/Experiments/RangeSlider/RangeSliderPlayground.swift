//
//  RangeSliderPlayground.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 13/04/2026.
//

import SwiftUI

struct RangeSliderPlayground: View {
    @State private var range: ClosedRange<Double> = 20...80
    @State private var steppedRange: ClosedRange<Double> = 2...8
    @State private var sizeRange: ClosedRange<Double> = 1...3
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Continuous: \(Int(range.lowerBound)) – \(Int(range.upperBound)) \(isEditing ? "(editing)" : "")")
                    .font(.headline)
                RangeSlider(range: $range, bounds: 0...100) { editing in
                    isEditing = editing
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Stepped with numeric labels: \(Int(steppedRange.lowerBound)) – \(Int(steppedRange.upperBound))")
                    .font(.headline)
                RangeSlider(range: $steppedRange, bounds: 0...10, step: 2) { value in
                    Text("\(Int(value))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Disabled")
                    .font(.headline)
                RangeSlider(range: $sizeRange, bounds: 0...4, step: 1) { value in
                    Text(["XS", "S", "M", "L", "XL"][Int(value)])
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .tint(.black)
                .disabled(true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Electra")
                    .font(.headline)
                RangeSlider(range: $sizeRange, bounds: 0...4, step: 1) { value in
                    Text(["XS", "S", "M", "L", "XL"][Int(value)])
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .tint(.cyan)
            }
        }
        .padding()
    }
}

#Preview {
    RangeSliderPlayground()
}
