# SlideToStop — Design

**Date:** 2026-05-29
**Status:** Approved
**Author:** Arnaud NOMMAY (with Claude)

## Summary

A self-contained SwiftUI experiment: a **Slide to Stop** control. The user must
deliberately drag a knob from the leading edge to the trailing edge of a capsule
track to trigger a "stop" action — a confirmation gesture that prevents an
accidental tap from killing something important (canonical use case: stopping an
active EV charging session, matching the app's existing charging UI in
`ToolBox.swift`).

The component is **dedicated and opinionated** (red, "Slide to stop", no
generic configuration), uses a **Liquid Glass knob**, and drives an **async
loading lifecycle** through a **binding-driven phase**.

## Approach

The component owns the drag interaction and every visual state (idle, dragging,
loading, success, failure). The **caller** owns the actual asynchronous stop work
and reports the result back through a shared `phase` binding. This was chosen
over an `async throws` closure so the caller keeps full control of the work and
its error handling, while the component stays a pure presentation/interaction
layer.

## Public API

```swift
enum SlideToStopPhase: Sendable {
    case idle       // ready; knob at leading edge
    case loading    // user completed the slide → caller should run the stop
    case success    // caller succeeded → checkmark, then auto-reset
    case failure    // caller failed → shake + spring back
}

struct SlideToStop: View {
    @Binding var phase: SlideToStopPhase
    init(phase: Binding<SlideToStopPhase>)
}
```

### Usage

```swift
@State private var phase: SlideToStopPhase = .idle

SlideToStop(phase: $phase)
    .padding(.horizontal)
    .task(id: phase) {                 // caller reacts to .loading
        guard phase == .loading else { return }
        do   { try await api.stopCharge(id); phase = .success }
        catch { phase = .failure }
    }
```

## State machine & ownership

| Transition | Who triggers it |
|---|---|
| `idle → loading` | **Component** — user drags knob past the threshold, or VoiceOver activate |
| `loading → success / failure` | **Caller** — sets the binding when async work resolves |
| `success → idle` | **Component** — auto-reset ~1.5s after the checkmark |
| `failure → idle` | **Component** — after a short error shake, springs the knob back |
| while `loading` / `success` / `failure` | dragging disabled; gesture ignored |

The component also honors a **programmatic** `phase = .loading` (stop triggered
elsewhere): the knob animates to the far end and shows the spinner without a
drag.

## Interaction & layout

- Full-width capsule, ~64pt tall (Dynamic Type–scaled). A glass knob ~56pt
  slides leading→trailing inside the track.
- Drag handled with `DragGesture(minimumDistance: 0)` in a **named coordinate
  space**, mirroring the technique in `RangeSlider.swift` so the touch point
  doesn't shift when the knob is repositioned mid-drag.
- `progress = clamp(touchX / (width − knobSize), 0...1)`.
- On release:
  - `progress ≥ 0.9` (completion threshold) → animate to full, then
    `phase = .loading`.
  - otherwise → spring back to `0`.
- A red fill capsule grows behind the knob as `progress` increases. The centered
  **"Slide to stop"** label fades out as `progress` rises.
- Idle affordance: animated chevrons `›››` shimmering toward the trailing edge
  (suppressed under Reduce Motion).

## Knob content by phase

| Phase | Knob content |
|---|---|
| `idle` / dragging | `chevron.right` |
| `loading` | `ProgressView()` spinner |
| `success` | `checkmark` |
| `failure` | `xmark` + horizontal shake, then spring back |

## Visuals & feedback

- **Knob:** `.glassEffect(.regular.interactive(), in: .circle)` on iOS 26; a
  shadowed white `Circle` fallback on earlier versions (mirrors `RangeSlider`'s
  `thumbShape`).
- **Track:** `.ultraThinMaterial` capsule; red fill (`Color.red`) behind the
  knob. Accent stays **red throughout**, including success (it is a *stop* — red
  fill, white checkmark), per approved design.
- **Haptics** via `.sensoryFeedback`: `.impact` on threshold-commit,
  `.success` on success, `.error` on failure.

## Accessibility

- Exposed as a **button**: accessibility label "Slide to stop charging", hint
  "Double tap to stop." VoiceOver double-tap drives `idle → loading` directly,
  since dragging is impractical for VoiceOver users.
- Honors `.disabled` / `isEnabled` (dimmed, gesture disabled).
- Dynamic Type via `@ScaledMetric` for track height / knob size.
- Reduce Motion drops the looping chevron shimmer; all functional transitions
  remain.

## Files

- `SwiftUIWorld/Experiments/SlideToStop/SlideToStop.swift` — the component plus
  `SlideToStopPhase`, with a header usage doc-comment in the style of
  `RangeSlider.swift`.
- `SwiftUIWorld/Experiments/SlideToStop/SlideToStopPlayground.swift` — a mock
  "charging session" card with `@State phase` and `.task(id:)` simulating a ~2s
  stop; includes a "make it fail" toggle and a disabled instance.
- `SwiftUIWorld/Experiments/ExperimentsView.swift` — register a new
  `Experiment(title: "Slide to Stop", systemImage: "bolt.slash.fill",
  destination: { AnyView(SlideToStopPlayground()) })`.

## Build integration

The Xcode project uses **file-system-synchronized groups**
(`PBXFileSystemSynchronizedRootGroup`), so new `.swift` files placed under the
`Experiments/` tree are included in the build automatically — no
`project.pbxproj` edits required. Only `ExperimentsView.swift` needs editing to
list the experiment.

## Out of scope (YAGNI)

- Generic / re-skinnable variants (Unlock / Confirm / Act). The mechanic is the
  same; if needed later, generalize from this component then.
- Right-to-left slide direction as a configurable option (standard left→right
  only; RTL locales handled by SwiftUI layout, not a new parameter).
- A closure-based or `async throws` API surface — superseded by the
  binding-driven phase.
