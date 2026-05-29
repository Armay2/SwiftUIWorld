# Slide to Stop Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans or implement inline task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. **No TDD** — this is a POC; verification is by Xcode build + SwiftUI `#Preview` + simulator, matching the repo's existing experiments (RangeSlider, CardWallet have no tests).

**Goal:** Add a `SlideToStop` experiment — a Liquid-Glass "slide to confirm" control that commits an async stop action via a binding-driven phase.

**Architecture:** A self-contained SwiftUI view owns the drag interaction and all visuals (idle / loading / success / failure). The caller owns the async work and reports results through a shared `@Binding var phase: SlideToStopPhase`. The component flips to `.loading` on a completed slide, the caller sets `.success`/`.failure`, and the component auto-resets to `.idle`.

**Tech Stack:** SwiftUI, iOS 18.6 deployment (`.glassEffect` gated to iOS 26 with a shadowed-circle fallback), Swift Concurrency for the demo's simulated stop.

**Spec:** `docs/superpowers/specs/2026-05-29-slide-to-stop-design.md`

---

### Task 1: The `SlideToStop` control + phase enum

**Files:**
- Create: `SwiftUIWorld/Experiments/SlideToStop/SlideToStop.swift`

- [ ] **Step 1: Create the file** with the phase enum and component below.

```swift
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
```

- [ ] **Step 2: Build for the simulator** and confirm it compiles.

Run (XcodeBuildMCP): `session_show_defaults` then `build_sim`.
Expected: BUILD SUCCEEDED, no warnings on the new file.

- [ ] **Step 3: Commit**

```bash
git add SwiftUIWorld/Experiments/SlideToStop/SlideToStop.swift
git commit -m "feat: add SlideToStop control"
```

---

### Task 2: The playground / showcase

**Files:**
- Create: `SwiftUIWorld/Experiments/SlideToStop/SlideToStopPlayground.swift`

- [ ] **Step 1: Create the file** below.

```swift
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
```

- [ ] **Step 2: Build** (XcodeBuildMCP `build_sim`). Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add SwiftUIWorld/Experiments/SlideToStop/SlideToStopPlayground.swift
git commit -m "feat: add SlideToStop playground"
```

---

### Task 3: Register the experiment

**Files:**
- Modify: `SwiftUIWorld/Experiments/ExperimentsView.swift` (append to `Experiment.all`, after the "Card Wallet" entry near line 68)

- [ ] **Step 1: Add the entry** as the last element of the `all` array:

```swift
        Experiment(title: "Slide to Stop",
                   systemImage: "bolt.slash.fill",
                   destination: { AnyView(SlideToStopPlayground()) }),
```

- [ ] **Step 2: Build + run on the simulator**, navigate to "Slide to Stop", screenshot.

Run (XcodeBuildMCP): `build_run_sim`, then `screenshot`.
Verify visually:
- Idle: capsule track, glass knob at left, "Slide to stop ›››" with shimmering chevrons.
- Drag right: red fill grows behind the knob, label fades; release before ~90% springs back.
- Release past ~90%: knob locks at end, spinner shows, status → "Stopping…".
- After ~2s: checkmark + haptic, status → "Charge stopped", then auto-resets to idle (~1.5s).
- Toggle "Simulate failure" on, slide: knob shakes, status → "Couldn't stop — try again", springs back.
- Disabled instance is dimmed and ignores drags.

- [ ] **Step 3: Commit**

```bash
git add SwiftUIWorld/Experiments/ExperimentsView.swift
git commit -m "feat: register Slide to Stop experiment"
```

---

## Self-Review

**Spec coverage:** API (`SlideToStopPhase`, `SlideToStop(phase:)`) → Task 1. State machine / ownership (commit → `.loading`; caller → `.success`/`.failure`; component → `.idle`) → Task 1 `react(to:)` + Task 2 `.task(id:)`. Drag math / threshold / named coordinate space → Task 1 `drag(travel:)`. Glass knob + fallback, red fill, fading label, shimmer chevrons → Task 1 subviews. Haptics → `.sensoryFeedback`. Accessibility (button, label, hint, activate, disabled, Dynamic Type, Reduce Motion) → Task 1. Files + registration → Tasks 1–3. Build integration (synchronized groups, no pbxproj edits) → Task 3 uses only `ExperimentsView.swift`. All spec sections covered.

**Placeholder scan:** No TBD/TODO; every code step is complete and compilable.

**Type consistency:** `SlideToStopPhase` cases (`idle`/`loading`/`success`/`failure`), `phase` binding, `progress`, `commit()`, `react(to:)`, `knobSize`, `threshold`, and the `space` coordinate-space name are used identically across Tasks 1–2. `SlideToStopPlayground` matches `SlideToStop(phase:)`. Registration in Task 3 matches the `Experiment` initializer shape used elsewhere in the file.
