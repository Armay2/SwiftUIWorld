# ToolBox — Native Bar + Liquid Glass Upgrade — Design

**Date:** 2026-05-29
**Status:** Approved
**Author:** Arnaud NOMMAY (with Claude)

## Summary

`ToolBox.swift` is an **EV charging-station finder** screen: a full-screen
`Map()` with floating controls for search, filtering, the user's profile, the
selected vehicle, and a **Plan / Nearby** toggle. The concept is good; the
**Liquid Glass implementation is incorrect** and the top bar is hand-rolled
where the system can do it better.

This upgrade keeps the concept and behavior but: (1) replaces the custom top
search capsule with a **native navigation bar** (`.toolbar` items +
`.searchable`), and (2) rebuilds the bottom panel using `GlassEffectContainer`
and `.glassEffect()` **the way Apple intends**. No new functionality — filter,
vehicle picker, and map content stay as stubs.

## Problem with the current code

The recurring mistake is **container-per-element plus `.glassEffect()` on the
wrapper**:

- Each control is wrapped in its *own* `GlassEffectContainer` (a container with a
  single child does nothing useful), **and** `.glassEffect()` is then applied to
  the parent `HStack`. The inner containers are no-ops; the result is one flat
  capsule instead of the fluid, blending glass the API is designed for.
- Buttons use `.buttonStyle(.plain)` instead of the iOS 26 `.glass` /
  `.glassProminent` styles.
- The top search row has a stray `Spacer()` and doubled padding.
- The Plan / Nearby toggle is contradictory: `isNearbySelected` defaults to
  `true`, yet **Plan** is the `.borderedProminent` (selected-looking) one.
- `ToolBox` is **not registered** in `Experiment.all`, so it is unreachable from
  the app, and it sits loose in `Experiments/` rather than its own folder.

## The core glass rule (applies everywhere)

> **One `GlassEffectContainer` per visual group. Each surface inside gets its own
> `.glassEffect(in:)`. Buttons use `.buttonStyle(.glass)` /
> `.glassProminent` — a glass button is itself a surface and needs no manual
> wrapping.** A shared `@Namespace` + `.glassEffectID(_:in:)` lets sibling
> surfaces blend and morph.

## Top bar — native navigation bar

`ToolBox` is always presented inside a `NavigationStack` (via `NavigationLink`
in `ExperimentsView`, and the `#Preview` wraps one), so the navigation bar and
`.searchable` work without adding a stack.

- Base: `Map().ignoresSafeArea()`. The nav bar floats above it with system
  Liquid Glass.
- `.navigationBarTitleDisplayMode(.inline)` with a minimal title (final value
  decided at build via screenshot — likely empty or a short brand label) so the
  map stays the hero.
- `.searchable(text: $searchText, prompt: "Find a station")` → native glass
  search field. **The custom `TextField` and the mic button are removed**;
  dictation comes from the system keyboard.
- Toolbar items (auto-glass on iOS 26):
  - `Image(systemName: "list.bullet")` button at `.topBarLeading`.
  - `Image(systemName: "slider.horizontal.3")` filter button at
    `.topBarTrailing`.
  - Opposite-side placement makes each its own glass capsule automatically — no
    `GlassEffectContainer` and no `ToolbarSpacer` needed (a `ToolbarSpacer` would
    only matter if two items shared one side).

## Bottom panel — three distinct glass cards

A single overlay pinned to the bottom of the `ZStack`, inside **one**
`GlassEffectContainer`, with a shared `@Namespace`:

- **Profile card** — `person.crop.circle.fill` + name + `chevron.down`;
  `.glassEffect(in: .rect(cornerRadius: 16))`, `.glassEffectID`.
- **Vehicle card** — `bolt.car.fill` (green) + `selectedVehicle` +
  `chevron.down`; same glass treatment.
- **Actions row** — `HStack` of two buttons:
  - **Plan** (`map`) and **Nearby** (`location.circle`) act as a 2-segment
    toggle driven by `isNearbySelected`.
  - **Selected segment** → `.buttonStyle(.glassProminent)` with an accent
    `.tint` (green, matching the bolt); **other** → `.buttonStyle(.glass)`.
  - Tapping a segment sets `isNearbySelected` accordingly; the prominent
    highlight follows. This resolves the current contradiction.

## State

Unchanged: `searchText`, `selectedVehicle`, `isNearbySelected`. Add one
`@Namespace` for `glassEffectID` grouping. No new model.

## Net change

**Removed:** the custom top capsule, every per-element `GlassEffectContainer`
wrapper, the `.glassEffect()`-on-wrapper pattern, the stray `Spacer()`, the
custom search `TextField` + mic, and all `.buttonStyle(.plain)`.

**Added:** `.searchable`, two toolbar items, one correctly-scoped
`GlassEffectContainer` for the bottom cards, native glass button styles, and the
toggle fix.

## Files

- `SwiftUIWorld/Experiments/ToolBox/ToolBox.swift` — the rewritten screen
  (moved into its own folder to match every other experiment). Keeps the
  `@available(iOS 26.0, *)` attribute and the `#Preview` wrapped in a
  `NavigationStack`.
- `SwiftUIWorld/Experiments/ExperimentsView.swift` — register the experiment:
  `Experiment(title: "ToolBox", systemImage: "bolt.car.fill", destination: { if #available(iOS 26.0, *) { AnyView(ToolBox()) } else { AnyView(Text("Only iOS 26+")) } })`,
  mirroring the availability handling already used for
  `ManualTransitionFullScreen`.

## Build integration

The `Experiments` group is a **traditional `PBXGroup`** with explicit children
(only the vendored `Lottie` folder is a `PBXFileSystemSynchronizedRootGroup`).
Therefore the file move is **not** automatic and must update
`project.pbxproj`:

- Create a `ToolBox/` folder/group with `path = ToolBox` (matching how
  `CardWallet` is structured) and move `ToolBox.swift` into it.
- Performed via the **Xcode MCP** (`XcodeMakeDir` + `XcodeMV`) so the file
  reference, group, and Sources build phase stay consistent. Manual
  `project.pbxproj` editing is the fallback if the MCP path fails.
- Verify with a build after the move.

## Verification

- Build for an iOS 26 simulator (`XcodeBuildMCP` `build_run_sim`).
- Screenshot the running screen and confirm: native nav bar with separate glass
  list/filter capsules, native search field, three blending bottom cards, and
  the Plan/Nearby prominent highlight switching on tap.
- Confirm ToolBox appears and opens from the Experiments list.

## Out of scope (YAGNI)

- Working filter sheet, vehicle picker menu, and Plan/Nearby actually changing
  map content — stubs remain stubs.
- Real map data, annotations, or user location.
- Any change to the bottom-panel structure beyond the glass fix (the
  three-distinct-cards layout was explicitly chosen over a combined card or a
  Maps-style bottom sheet).
