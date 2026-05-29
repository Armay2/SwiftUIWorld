//
//  RangeSlider.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 13/04/2026.
//
//  A two-thumb range slider. Drop this single file into any SwiftUI project.
//
//  Usage:
//      @State var range: ClosedRange<Double> = 20...80
//      RangeSlider(range: $range, bounds: 0...100)
//
//      // With step snapping + tick labels:
//      RangeSlider(range: $range, bounds: 0...10, step: 1) { value in
//          Text("\(Int(value))").font(.caption2)
//      }
//
//  Honors `.tint(_:)`, `.disabled(_:)`, and Dynamic Type. Tap-to-jump is
//  supported (tapping anywhere on the track moves the nearest thumb).
//

import SwiftUI

/// A two-thumb slider that edits a `ClosedRange<Double>` within a fixed `bounds` range.
///
/// Supports optional step snapping, tick labels under the track, tap-to-jump on the track,
/// VoiceOver adjustable actions, Dynamic Type, Liquid Glass thumbs on iOS 26, and haptic
/// feedback on value changes.
///
/// - Note: When `step` does not divide `(bounds.upperBound - bounds.lowerBound)` evenly,
///   the exact `bounds.upperBound` may be unreachable by the upper thumb (snapping rounds
///   to the nearest step multiple).
struct RangeSlider<TickLabel: View>: View {
    /// The currently selected range. Always clamped inside `bounds`.
    @Binding var range: ClosedRange<Double>
    /// The fixed minimum and maximum the slider allows.
    let bounds: ClosedRange<Double>
    /// If set, the range snaps to multiples of this value.
    var step: Double? = nil
    /// Fires `true` when a drag starts, `false` when it ends. Matches `Slider`'s convention.
    var onEditingChanged: (Bool) -> Void = { _ in }
    /// View builder that renders a label under each step tick.
    var tickLabel: (Double) -> TickLabel

    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric(relativeTo: .caption) private var labelHeight: CGFloat = 18

    @State private var editingThumb: Thumb? = nil

    private let thumbSize: CGFloat = 28
    private let trackHeight: CGFloat = 4
    private let tickDotSize: CGFloat = 6
    private let labelSpacing: CGFloat = 6
    private let trackSpace = "rangeSliderTrack"

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let usable = max(width - thumbSize, 0)
            let lowerX = position(for: range.lowerBound, in: usable)
            let upperX = position(for: range.upperBound, in: usable)
            let ticks = tickValues()

            VStack(spacing: labelSpacing) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: trackHeight)
                        .padding(.horizontal, thumbSize / 2)

                    Capsule()
                        .fill(.tint)
                        .frame(width: max(upperX - lowerX, 0), height: trackHeight)
                        .offset(x: lowerX + thumbSize / 2)

                    thumb(for: .lower)
                        .offset(x: lowerX)

                    thumb(for: .upper)
                        .offset(x: upperX)
                }
                .frame(height: thumbSize)
                .coordinateSpace(name: trackSpace)
                .contentShape(Rectangle())
                .gesture(trackDragGesture(usable: usable))

                if !ticks.isEmpty {
                    ZStack(alignment: .topLeading) {
                        // Invisible spacer establishes the row's frame so .position() has a known coordinate space.
                        Color.clear.frame(height: tickSectionHeight)

                        ForEach(ticks, id: \.self) { value in
                            VStack(spacing: labelSpacing) {
                                Circle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: tickDotSize, height: tickDotSize)
                                tickLabel(value)
                                    .fixedSize()
                                    .frame(height: labelHeight)
                            }
                            .position(
                                x: position(for: value, in: usable) + thumbSize / 2,
                                y: tickSectionHeight / 2
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
        .frame(height: thumbSize + (hasTicks ? labelSpacing + tickSectionHeight : 0))
        .opacity(isEnabled ? 1 : 0.5)
        .sensoryFeedback(.selection, trigger: range.lowerBound)
        .sensoryFeedback(.selection, trigger: range.upperBound)
        .onChange(of: bounds) { _, newBounds in
            // Keep the selected range valid if the caller narrows the allowed bounds.
            let newLower = range.lowerBound.clamped(to: newBounds)
            let newUpper = range.upperBound.clamped(to: newBounds)
            if newLower != range.lowerBound || newUpper != range.upperBound {
                range = newLower...max(newLower, newUpper)
            }
        }
    }

    private var hasTicks: Bool { (step ?? 0) > 0 }
    private var tickSectionHeight: CGFloat { tickDotSize + labelSpacing + labelHeight }

    // MARK: - Thumb

    private func thumb(for thumb: Thumb) -> some View {
        thumbShape
            .frame(width: thumbSize, height: thumbSize)
            .accessibilityElement()
            .accessibilityLabel(thumb == .lower ? "Minimum value" : "Maximum value")
            .accessibilityValue(accessibilityValueText(for: thumb))
            .accessibilityAdjustableAction { direction in
                adjust(thumb, direction: direction)
            }
    }

    @ViewBuilder
    private var thumbShape: some View {
        if #available(iOS 26.0, *) {
            Circle()
                .fill(.clear)
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            Circle()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                .overlay(Circle().stroke(Color.gray.opacity(0.2)))
        }
    }

    private func accessibilityValueText(for thumb: Thumb) -> String {
        let v = thumb == .lower ? range.lowerBound : range.upperBound
        return step.map { _ in "\(Int(v))" } ?? String(format: "%.2f", v)
    }

    private func adjust(_ thumb: Thumb, direction: AccessibilityAdjustmentDirection) {
        let delta = step ?? (bounds.upperBound - bounds.lowerBound) / 20
        let sign: Double = direction == .increment ? 1 : -1
        let newRange: ClosedRange<Double>
        switch thumb {
        case .lower:
            let new = (range.lowerBound + sign * delta).clamped(to: bounds.lowerBound...range.upperBound)
            newRange = new...range.upperBound
        case .upper:
            let new = (range.upperBound + sign * delta).clamped(to: range.lowerBound...bounds.upperBound)
            newRange = range.lowerBound...new
        }
        if newRange != range { range = newRange }
    }

    // MARK: - Math

    private enum Thumb { case lower, upper }

    private func tickValues() -> [Double] {
        guard let step, step > 0 else { return [] }
        return Array(stride(from: bounds.lowerBound, through: bounds.upperBound, by: step))
    }

    private func position(for value: Double, in usable: CGFloat) -> CGFloat {
        let span = bounds.upperBound - bounds.lowerBound
        guard span > 0 else { return 0 }
        let ratio = (value - bounds.lowerBound) / span
        return CGFloat(ratio) * usable
    }

    private func value(forX x: CGFloat, usable: CGFloat) -> Double {
        guard usable > 0 else { return bounds.lowerBound }
        let ratio = Double(max(0, min(x, usable)) / usable)
        var v = bounds.lowerBound + ratio * (bounds.upperBound - bounds.lowerBound)
        if let step, step > 0 {
            v = (v / step).rounded() * step
        }
        return v.clamped(to: bounds)
    }

    private func trackDragGesture(usable: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(trackSpace))
            .onChanged { g in
                // g.location is in the track's fixed coordinate space, so it doesn't
                // shift when the thumb is repositioned mid-drag.
                let touchX = g.location.x - thumbSize / 2
                let target = value(forX: touchX, usable: usable)

                let thumb = editingThumb ?? nearestThumb(to: target)
                if editingThumb == nil {
                    editingThumb = thumb
                    onEditingChanged(true)
                }

                let newRange: ClosedRange<Double> = {
                    switch thumb {
                    case .lower: return min(target, range.upperBound)...range.upperBound
                    case .upper: return range.lowerBound...max(target, range.lowerBound)
                    }
                }()
                if newRange != range { range = newRange }
            }
            .onEnded { _ in
                editingThumb = nil
                onEditingChanged(false)
            }
    }

    private func nearestThumb(to value: Double) -> Thumb {
        abs(value - range.lowerBound) <= abs(value - range.upperBound) ? .lower : .upper
    }
}

extension RangeSlider where TickLabel == EmptyView {
    /// Initializes a `RangeSlider` without tick labels.
    init(
        range: Binding<ClosedRange<Double>>,
        bounds: ClosedRange<Double>,
        step: Double? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._range = range
        self.bounds = bounds
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.tickLabel = { _ in EmptyView() }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    @Previewable @State var range: ClosedRange<Double> = 20...80
    return RangeSlider(range: $range, bounds: 0...100)
        .padding()
}
