//
//  SlideToStop.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 29/05/2026.
//
//  A "slide to stop" confirmation control. The user drags a glass knob from the
//  leading edge to the trailing edge to commit an important/destructive action
//  (e.g. stopping an EV charging session), preventing accidental taps.
//
//  Usage:
//      @State private var phase: SlideToStopPhase = .idle
//
//      SlideToStop(phase: $phase)
//          .task(id: phase) {
//              guard phase == .loading else { return }
//              do   { try await stopCharge(); phase = .success }
//              catch { phase = .failure }
//          }
//
//  The component owns the drag interaction and all visuals. The caller observes
//  `.loading`, performs the async work, and reports `.success` / `.failure`.
//  The component auto-resets to `.idle` after success (~1.5s) and after failure.
//

import SwiftUI

/// Lifecycle of a ``SlideToStop`` control, shared between the control and its caller.
enum SlideToStopPhase: Sendable {
    /// Ready; the knob rests at the leading edge.
    case idle
    /// The user completed the slide. The caller should run its async stop work.
    case loading
    /// The caller's work succeeded; shows a checkmark, then auto-resets.
    case success
    /// The caller's work failed; shakes, then springs the knob back.
    case failure
}

struct SlideToStop: View {
    @Binding var phase: SlideToStopPhase

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .body) private var trackHeight: CGFloat = 64
    @State private var progress: CGFloat = 0     // knob travel, 0...1
    @State private var shake: CGFloat = 0
    @State private var shimmer: CGFloat = 0

    private let inset: CGFloat = 5
    private let threshold: CGFloat = 0.9
    private let space = "slideToStopTrack"
    private let spring = Animation.spring(response: 0.35, dampingFraction: 0.72)

    private var knobSize: CGFloat { trackHeight - inset * 2 }
    private var isInteractive: Bool { phase == .idle && isEnabled }

    var body: some View {
        GeometryReader { geo in
            let travel = max(geo.size.width - knobSize - inset * 2, 0)
            let knobX = inset + progress * travel

            ZStack(alignment: .leading) {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(Color.red.gradient)
                    .frame(width: knobX + knobSize + inset)
            }
            .clipShape(Capsule())
            .overlay { label.opacity(Double(max(0, 1 - progress * 1.6))) }
            .overlay(alignment: .leading) {
                knob
                    .offset(x: knobX + shake)
                    .gesture(drag(travel: travel))
            }
            .coordinateSpace(name: space)
        }
        .frame(height: trackHeight)
        .frame(maxWidth: .infinity)
        .opacity(isEnabled ? 1 : 0.45)
        .sensoryFeedback(trigger: phase) { _, new -> SensoryFeedback? in
            switch new {
            case .loading: return .impact
            case .success: return .success
            case .failure: return .error
            case .idle:    return nil
            }
        }
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Slide to stop charging")
        .accessibilityHint("Double tap to stop.")
        .accessibilityAction { commit() }
        .onChange(of: phase) { _, new in react(to: new) }
        .onAppear { startShimmer() }
    }

    // MARK: - Subviews

    private var label: some View {
        HStack(spacing: 8) {
            Text("Slide to stop")
                .font(.headline)
                .foregroundStyle(.secondary)
            chevrons
        }
    }

    private var chevrons: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                Image(systemName: "chevron.right").opacity(chevronOpacity(i))
            }
        }
        .font(.subheadline.weight(.bold))
        .foregroundStyle(.red)
    }

    private func chevronOpacity(_ i: Int) -> Double {
        guard !reduceMotion else { return 0.5 }
        let d = abs(shimmer - Double(i))
        return max(0.25, 1 - d * 0.6)
    }

    private var knob: some View {
        ZStack { knobBackground; knobIcon }
            .frame(width: knobSize, height: knobSize)
            .contentShape(Circle())
    }

    @ViewBuilder
    private var knobBackground: some View {
        if #available(iOS 26.0, *) {
            Circle().fill(.clear).glassEffect(.regular.interactive(), in: .circle)
        } else {
            Circle().fill(.white).shadow(color: .black.opacity(0.25), radius: 3, y: 1)
        }
    }

    @ViewBuilder
    private var knobIcon: some View {
        Group {
            switch phase {
            case .idle:    Image(systemName: "chevron.right")
            case .loading: ProgressView().controlSize(.small)
            case .success: Image(systemName: "checkmark")
            case .failure: Image(systemName: "xmark")
            }
        }
        .font(.body.weight(.bold))
        .foregroundStyle(.red)
        .tint(.red)
    }

    // MARK: - Interaction

    private func drag(travel: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged { g in
                guard isInteractive, travel > 0 else { return }
                let x = g.location.x - inset - knobSize / 2
                progress = min(max(x / travel, 0), 1)
            }
            .onEnded { _ in
                guard isInteractive else { return }
                if progress >= threshold { commit() }
                else { withAnimation(spring) { progress = 0 } }
            }
    }

    private func commit() {
        guard isInteractive else { return }
        phase = .loading            // react(to:) drives the knob to the end
    }

    private func react(to new: SlideToStopPhase) {
        switch new {
        case .idle:
            withAnimation(spring) { progress = 0 }
        case .loading:
            withAnimation(spring) { progress = 1 }
        case .success:
            withAnimation(spring) { progress = 1 }
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                if phase == .success { phase = .idle }
            }
        case .failure:
            shakeKnob()
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                if phase == .failure { phase = .idle }
            }
        }
    }

    private func shakeKnob() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: 0.07).repeatCount(5, autoreverses: true)) {
            shake = 8
        }
        Task {
            try? await Task.sleep(for: .seconds(0.4))
            shake = 0
        }
    }

    private func startShimmer() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
            shimmer = 3
        }
    }
}

#Preview {
    @Previewable @State var phase: SlideToStopPhase = .idle
    return SlideToStop(phase: $phase)
        .padding()
        .task(id: phase) {
            guard phase == .loading else { return }
            try? await Task.sleep(for: .seconds(2))
            phase = .success
        }
}
