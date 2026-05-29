//
//  SlideToStop.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 29/05/2026.
//
//  A "slide to stop" confirmation control. The user drags a glossy knob from the
//  leading edge to the trailing edge to commit an important/destructive action
//  (e.g. stopping an EV charging session), preventing accidental taps.
//
//  Self-contained, drop-in component: it depends only on SwiftUI and defines
//  everything it needs in this single file — the `SlideToStopPhase` enum, the
//  private `Shimmer` modifier, and its private color palette. Copy this one file
//  into any SwiftUI project to use it; nothing else is required.
//
//  Requirements:
//      • iOS 18+ (uses `onGeometryChange`). For iOS 17, swap that one modifier for
//        a `GeometryReader` reading `geo.size.width`.
//      • On iOS 26+ the knob is a native Liquid Glass lens; earlier versions fall
//        back to a glossy gradient sphere automatically.
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
//  Localization: the visible label and VoiceOver strings are French
//  ("Glisser pour arrêter"). Change the `title` constant and the accessibility
//  strings to retheme or localize.
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

    @ScaledMetric(relativeTo: .title3) private var trackHeight: Double = 72
    @State private var trackWidth: Double = 0
    @State private var progress: Double = 0     // knob travel, 0...1
    @State private var shake: Double = 0
    @State private var shimmer: Double = 0      // 0...1 highlight sweep
    @State private var pressed = false

    private let title = "Glisser pour arrêter"
    private let inset: Double = 5
    private let threshold: Double = 0.9
    private let space = "slideToStopTrack"
    private let spring = Animation.spring(response: 0.35, dampingFraction: 0.72)

    private var knobSize: Double { trackHeight - inset * 2 }
    private var isInteractive: Bool { phase == .idle && isEnabled }
    private var pastThreshold: Bool { progress >= threshold }

    var body: some View {
        let travel = max(trackWidth - knobSize - inset * 2, 0)
        let knobX = inset + progress * travel

        track
            .overlay { label }
            .overlay(alignment: .leading) {
                knob
                    .offset(x: knobX + shake)
                    .gesture(drag(travel: travel))
            }
            .coordinateSpace(name: space)
            .onGeometryChange(for: Double.self) { proxy in
                Double(proxy.size.width)
            } action: { newWidth in
                trackWidth = newWidth
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
            // Soft tick when the knob is grabbed.
            .sensoryFeedback(trigger: pressed) { _, isPressed in
                isPressed ? .impact(flexibility: .soft, intensity: 0.6) : nil
            }
            // Crisp detent when the slide crosses the completion threshold mid-drag.
            .sensoryFeedback(trigger: pastThreshold) { _, reached in
                (pressed && reached) ? .impact(flexibility: .rigid) : nil
            }
            .accessibilityElement()
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("Glisser pour arrêter la charge")
            .accessibilityHint("Toucher deux fois pour arrêter.")
            .accessibilityAction { commit() }
            .onChange(of: phase) { _, new in react(to: new) }
            .onAppear { startShimmer() }
            .task(id: phase) { await autoReset() }
    }

    // MARK: - Subviews

    private var track: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.stopTrack, .stopTrack.opacity(0.9)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay {
                Capsule().strokeBorder(.black.opacity(0.25), lineWidth: 1)
            }
    }

    private var label: some View {
        ZStack {
            // When Reduce Motion is on the brightening shimmer is suppressed, so the
            // resting text is raised to a readable opacity instead.
            styledTitle.foregroundStyle(.white.opacity(reduceMotion ? 0.9 : 0.5))
            if !reduceMotion {
                styledTitle
                    .foregroundStyle(.white)
                    .modifier(Shimmer(phase: shimmer))
            }
        }
        .padding(.horizontal, knobSize + inset * 2)
        .allowsHitTesting(false)
    }

    private var styledTitle: some View {
        Text(title)
            .font(.title2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }

    private var knob: some View {
        knobSurface
            .overlay { knobIcon }
            .frame(width: knobSize, height: knobSize)
            .scaleEffect(pressed ? (reduceMotion ? 1 : 1.4) : 1)
            .shadow(color: .black.opacity(0.4), radius: pressed ? 10 : 6, y: pressed ? 5 : 3)
            .contentShape(.circle)
    }

    @ViewBuilder
    private var knobSurface: some View {
        if #available(iOS 26.0, *) {
            // Native Liquid Glass: the most transparent `.clear` lens, interactive.
            Circle()
                .fill(.clear)
                .glassEffect(.clear.interactive(), in: .circle)
        } else {
            // Glossy teal sphere fallback for pre-iOS 26.
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.stopKnobTop, .stopKnobBottom],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.4), .clear],
                            center: UnitPoint(x: 0.35, y: 0.28),
                            startRadius: 0, endRadius: knobSize * 0.55
                        )
                    )
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.05)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        }
    }

    @ViewBuilder
    private var knobIcon: some View {
        switch phase {
        case .idle:
            RoundedRectangle(cornerRadius: knobSize * 0.1)
                .fill(.white)
                .frame(width: knobSize * 0.42, height: knobSize * 0.42)
        case .loading:
            ProgressView().controlSize(.small).tint(.white)
        case .success:
            Image(systemName: "checkmark").font(.title3.bold()).foregroundStyle(.white)
        case .failure:
            Image(systemName: "xmark").font(.title3.bold()).foregroundStyle(.white)
        }
    }

    // MARK: - Interaction

    private func drag(travel: Double) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged { g in
                guard isInteractive, travel > 0 else { return }
                if !pressed { withAnimation(spring) { pressed = true } }
                let x = Double(g.location.x) - inset - knobSize / 2
                progress = min(max(x / travel, 0), 1)
            }
            .onEnded { _ in
                guard isInteractive else { return }
                withAnimation(spring) { pressed = false }
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
        case .idle:    withAnimation(spring) { progress = 0 }
        case .loading: withAnimation(spring) { progress = 1 }
        case .success: withAnimation(spring) { progress = 1 }
        case .failure: shakeKnob()
        }
    }

    /// Returns the control to `.idle` shortly after a success or failure. Driven by
    /// `.task(id: phase)`, so it cancels automatically if the phase changes or the
    /// view disappears.
    private func autoReset() async {
        let delay: Duration
        switch phase {
        case .success: delay = .seconds(1.5)
        case .failure: delay = .seconds(0.6)
        default: return
        }
        try? await Task.sleep(for: delay)
        if !Task.isCancelled { phase = .idle }
    }

    private func shakeKnob() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: 0.07).repeatCount(6, autoreverses: true)) {
            shake = 8
        } completion: {
            shake = 0
        }
    }

    private func startShimmer() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
            shimmer = 1
        }
    }
}

/// Masks a view with a narrow bright band that sweeps left-to-right as `phase`
/// goes 0 → 1 — the classic "slide to unlock" text shimmer.
private struct Shimmer: ViewModifier {
    var phase: Double

    func body(content: Content) -> some View {
        content.mask {
            // GeometryReader is the right tool here: the band width is relative to
            // the masked text's own size, read live inside the mask.
            GeometryReader { geo in
                let w = geo.size.width
                LinearGradient(
                    colors: [.clear, .white, .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: w * 0.6)
                .offset(x: -w + CGFloat(phase) * 2 * w)
            }
        }
    }
}

private extension Color {
    static let stopTrack = Color(red: 0.10, green: 0.28, blue: 0.32)
    static let stopKnobTop = Color(red: 0.17, green: 0.40, blue: 0.45)
    static let stopKnobBottom = Color(red: 0.06, green: 0.18, blue: 0.21)
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
