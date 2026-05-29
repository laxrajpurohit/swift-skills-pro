---
name: swift-performance-pro
description: Use when diagnosing or fixing performance — SwiftUI render cost, memory and retain cycles, slow lists, launch time, and using Instruments.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Performance Pro

Find and fix performance problems with evidence, not guesses. Measure first.

## When to use

- Janky scrolling, slow launch, high memory, or battery drain.
- Reviewing code for performance regressions.
- Planning an Instruments session.

Trigger: `/swift-performance-pro`.

## Core principles

- Measure before optimizing — use Instruments (Time Profiler, Allocations, SwiftUI,
  Leaks), not intuition.
- Keep SwiftUI `body` cheap and pure; recomputation is frequent.
- Do heavy work off the main actor.
- Don't optimize what you haven't proven is hot.

## SwiftUI render cost

Keep `body` free of side effects and heavy compute.

❌ Sorting on every render
```swift
var body: some View {
    List(items.sorted { $0.date > $1.date }) { Row($0) }   // re-sorts each pass
}
```
✅ Sort once in the model
```swift
// model exposes already-sorted `items`
var body: some View { List(model.items) { Row($0) } }
```

Narrow observation so unrelated changes don't redraw everything. Split big views into
small subviews so SwiftUI can diff precisely.

## Lists

- `LazyVStack`/`List` for long content, not eager `VStack` in a `ScrollView`.
- Stable `Identifiable` IDs — index-based identity forces full rebuilds.
- Avoid `AnyView` in row builders; it defeats SwiftUI's diffing.

## Memory & retain cycles

❌ Strong self capture in a stored closure
```swift
manager.onUpdate = { self.refresh() }   // cycle: manager → closure → self
```
✅
```swift
manager.onUpdate = { [weak self] in self?.refresh() }
```
Verify `deinit` runs. Use Instruments → Leaks / Allocations to confirm.

## Off the main actor

❌
```swift
let image = UIImage(data: hugeData)   // decode on main → dropped frames
```
✅
```swift
let image = await Task.detached { UIImage(data: hugeData) }.value
```
Downsample large images to the display size instead of loading full-resolution.

## Launch time

- Defer non-critical work out of `init`/`onAppear`; load it in `.task`.
- Avoid synchronous disk/network on the launch path.
- Audit with Instruments → App Launch.

## Common mistakes checklist

- [ ] Sorting/filtering/heavy compute inside `body`.
- [ ] Eager `VStack` where `LazyVStack`/`List` is needed.
- [ ] Index-based identity forcing full list rebuilds.
- [ ] `AnyView` in hot row builders.
- [ ] Strong `self` in stored closures (retain cycle).
- [ ] Image decode / disk / network on the main actor or launch path.
- [ ] Optimizing without an Instruments trace proving the hotspot.

## Output format (when reviewing)

Per issue: file:line, the cost, before/after, and which Instrument confirms it. Lead with
main-thread blockers.
