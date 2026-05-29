# ToolBox Native Bar + Liquid Glass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `ToolBox.swift`'s UI to use a native iOS 26 navigation bar (`.toolbar` + `.searchable`) and correct Liquid Glass (`GlassEffectContainer` + `.glassEffect`), and make the experiment reachable.

**Architecture:** A full-screen `Map()` in a bottom-aligned `ZStack`. The top controls become a system navigation bar (auto-glass) with `.searchable`; the bottom panel becomes one `GlassEffectContainer` holding three glass cards (profile, vehicle, Plan/Nearby toggle). `ToolBox` is registered in `Experiment.all` and moved into its own folder.

**Tech Stack:** SwiftUI, MapKit, iOS 26 Liquid Glass APIs. No unit tests exist for views in this project — **verification is `XcodeBuildMCP` build + `screenshot`**, plus visually confirming the spec's checklist.

**Spec:** `docs/superpowers/specs/2026-05-29-toolbox-native-glass-design.md`

---

## File Structure

- `SwiftUIWorld/Experiments/ToolBox.swift` (existing) → rewritten, then moved to `SwiftUIWorld/Experiments/ToolBox/ToolBox.swift`. One responsibility: the charging-finder screen.
- `SwiftUIWorld/Experiments/ExperimentsView.swift` (existing) → add one `Experiment` entry. Responsibility: the experiment registry.
- `SwiftUIWorld.xcodeproj/project.pbxproj` → group/reference update for the folder move (Task 3).

---

## Task 1: Register ToolBox + establish the build/screenshot loop

**Files:**
- Modify: `SwiftUIWorld/Experiments/ExperimentsView.swift:66-68` (the Card Wallet entry, end of `all`)

- [ ] **Step 1: Confirm simulator defaults**

Use the XcodeBuildMCP tool `session_show_defaults`. Confirm project/workspace = `SwiftUIWorld`, scheme = `SwiftUIWorld`, and a simulator running **iOS 26+** is selected.
If anything is missing: run `list_sims`, pick an iOS 26 device, then `session_set_defaults`.

- [ ] **Step 2: Baseline build & run**

Use `build_run_sim` (empty args if defaults are set). Then `screenshot`.
Expected: the app launches to the **Experiments** list. Confirm "ToolBox" is **absent** (baseline).

- [ ] **Step 3: Register the experiment**

In `ExperimentsView.swift`, add this entry as the last element of `Experiment.all`, immediately after the `Card Wallet` entry (after line 68's `}),`) and before the closing `]`:

```swift
        Experiment(title: "ToolBox",
                   systemImage: "bolt.car.fill",
                   destination: {
                       if #available(iOS 26.0, *) {
                           AnyView(ToolBox())
                       } else {
                           AnyView(Text("Only iOS 26+"))
                       }
                   }),
```

- [ ] **Step 4: Build, run, verify it appears**

Use `build_run_sim`, then `screenshot`.
Expected: build succeeds; the Experiments list now shows a "ToolBox" row with a `bolt.car.fill` icon. Tap it (use the XcodeBuildMCP UI automation `snapshot_ui` to find the row's coordinates, then a tap) and `screenshot`.
Expected: the **current (old)** ToolBox screen renders without crashing.

- [ ] **Step 5: Commit**

First inspect what's staged so you don't sweep unrelated work-in-progress:

```bash
git diff -- SwiftUIWorld/Experiments/ExperimentsView.swift
```

If the only meaningful change is the new entry, commit just that file:

```bash
git add SwiftUIWorld/Experiments/ExperimentsView.swift
git commit -m "feat(toolbox): register ToolBox in the experiments list"
```

If the file contains other uncommitted edits you didn't make, stop and surface them to the user before committing.

---

## Task 2: Rewrite ToolBox.swift — native bar + correct Liquid Glass

**Files:**
- Modify (full rewrite): `SwiftUIWorld/Experiments/ToolBox.swift`

- [ ] **Step 1: Replace the file contents**

Replace the entire body of `SwiftUIWorld/Experiments/ToolBox.swift` with:

```swift
//
//  ToolBox.swift
//  SwiftUIWorld
//
//  Created by Arnaud NOMMAY on 30/04/2026.
//

import SwiftUI
import MapKit

@available(iOS 26.0, *)
struct ToolBox: View {
    @State private var searchText: String = ""
    @State private var selectedVehicle: String = "Tesla Model 3"
    @State private var isNearbySelected: Bool = true

    @Namespace private var glassNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            Map()
                .ignoresSafeArea()

            bottomPanel
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Find a station")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // stations list
                } label: {
                    Image(systemName: "list.bullet")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // filters
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
    }

    // MARK: - Bottom panel

    private var bottomPanel: some View {
        GlassEffectContainer(spacing: 12) {
            VStack(spacing: 12) {
                profileCard
                vehicleCard
                actionsRow
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 22))
            Text("ARNAUD NOMMAY")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Button {
                // account menu
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .glassEffectID("profile", in: glassNamespace)
    }

    private var vehicleCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "bolt.car.fill")
                .font(.system(size: 18))
                .foregroundStyle(.green)
            Text(selectedVehicle)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Button {
                // vehicle menu
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .glassEffectID("vehicle", in: glassNamespace)
    }

    private var actionsRow: some View {
        HStack(spacing: 12) {
            actionButton(
                title: "Plan",
                systemImage: "map",
                isSelected: !isNearbySelected
            ) {
                isNearbySelected = false
            }

            actionButton(
                title: "Nearby",
                systemImage: "location.circle",
                isSelected: isNearbySelected
            ) {
                isNearbySelected = true
            }
        }
        .controlSize(.large)
        .tint(.green)
    }

    @ViewBuilder
    private func actionButton(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let label = Label(title, systemImage: systemImage)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

        if isSelected {
            Button(action: action) { label }
                .buttonStyle(.glassProminent)
        } else {
            Button(action: action) { label }
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    NavigationStack {
        if #available(iOS 26.0, *) {
            ToolBox()
        } else {
            Text("Only iOS 26+")
        }
    }
}
```

- [ ] **Step 2: Build**

Use `build_sim`.
Expected: build succeeds. If the compiler rejects `.buttonStyle(.glass)` / `.glassProminent`, `glassEffect(in:)`, or `glassEffectID(_:in:)`, the SDK isn't iOS 26 — re-check the simulator/SDK from Task 1 before changing the code.

- [ ] **Step 3: Run & screenshot**

Use `build_run_sim`, navigate to ToolBox (tap the row), `screenshot`.
Verify against the spec:
  - Top: native nav bar with a `list.bullet` capsule on the left, a `slider.horizontal.3` capsule on the right, both rendered as Liquid Glass.
  - A native search field (prompt "Find a station") is present.
  - Bottom: three glass cards — profile, vehicle (green bolt), and a Plan/Nearby row.
  - **Nearby** is the highlighted (prominent) segment on launch (since `isNearbySelected == true`). Tap **Plan** → the prominent highlight moves to Plan. `screenshot` to confirm the swap.

- [ ] **Step 4: Tune if the screenshot demands it**

Cosmetic-only, decided from the screenshot (not blockers):
  - If the search field looks wrong over the non-scrolling `Map` (e.g. opaque bar), try adding `.toolbarBackgroundVisibility(.hidden, for: .navigationBar)` to the `ZStack`.
  - If the action buttons are too short/tall, adjust `.padding(.vertical, 8)` in `actionButton`.
  - If you want a title, set `.navigationTitle("Charge")`; otherwise leave it empty.
Re-`build_run_sim` + `screenshot` after any tweak.

- [ ] **Step 5: Commit**

```bash
git add SwiftUIWorld/Experiments/ToolBox.swift
git commit -m "feat(toolbox): native navigation bar + correct Liquid Glass"
```

---

## Task 3: Move ToolBox.swift into its own folder

**Files:**
- Move: `SwiftUIWorld/Experiments/ToolBox.swift` → `SwiftUIWorld/Experiments/ToolBox/ToolBox.swift`
- Modify: `SwiftUIWorld.xcodeproj/project.pbxproj` (group + reference, handled by the move)

The `Experiments` group is a traditional `PBXGroup`, so the move must update the project file.

- [ ] **Step 1: Move via the Xcode MCP (preferred)**

Use the `xcode` MCP tools: `XcodeMakeDir` to create group `SwiftUIWorld/Experiments/ToolBox`, then `XcodeMV` to move `ToolBox.swift` into it. These keep `project.pbxproj` (the `PBXFileReference`, the new `PBXGroup`, and the Sources build phase) consistent.

- [ ] **Step 2: Fallback — manual move (only if the MCP path fails)**

```bash
mkdir SwiftUIWorld/Experiments/ToolBox
git mv SwiftUIWorld/Experiments/ToolBox.swift SwiftUIWorld/Experiments/ToolBox/ToolBox.swift
```

Then edit `SwiftUIWorld.xcodeproj/project.pbxproj` to mirror how `CardWallet` is structured (a `PBXGroup` with `path = ToolBox` containing the file reference):
  - Add a new `PBXGroup` (generate a fresh 24-char uppercase-hex ID) with `path = ToolBox;` and `children = ( <existing ToolBox.swift fileRef ID> );`.
  - In the `Experiments` group's `children`, replace the bare `<ToolBox.swift fileRef ID> /* ToolBox.swift */,` line with `<new group ID> /* ToolBox */,`.
The existing `PBXFileReference` (`path = ToolBox.swift; sourceTree = "<group>";`) and the Sources `PBXBuildFile` entry stay as-is.

- [ ] **Step 3: Build & run to confirm the project is intact**

Use `build_run_sim`, navigate to ToolBox, `screenshot`.
Expected: build succeeds and the screen is unchanged from Task 2.

- [ ] **Step 4: Commit**

```bash
git add -A SwiftUIWorld/Experiments/ SwiftUIWorld.xcodeproj/project.pbxproj
git commit -m "chore(toolbox): move into its own Experiments folder"
```

---

## Notes for the executor

- **Pre-existing working tree:** `ToolBox.swift` is already staged as a new file and `ExperimentsView.swift` has uncommitted edits from before this work. Inspect diffs before each commit and keep commits scoped to this task's intent.
- **`docs/` is untracked.** The spec and this plan are not committed. Commit them only if the user asks.
- **Don't touch** `~/.claude/**`, settings, or hooks. No project-control changes beyond the `project.pbxproj` group edit described in Task 3.
