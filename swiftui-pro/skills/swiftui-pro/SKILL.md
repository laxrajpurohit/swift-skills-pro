---
name: swiftui-pro
description: Use when writing, reviewing, or refactoring SwiftUI code — covers modern state management (@Observable), NavigationStack, layout, performance, and accessibility for iOS 26 / Swift 6.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# SwiftUI Pro

Write and review SwiftUI for correctness, modern APIs, and performance. Report real
problems only — no nitpicking.

## When to use

- Writing new SwiftUI views.
- Reviewing or refactoring existing SwiftUI.
- Fixing layout, state, navigation, or performance issues.

Trigger: `/swiftui-pro` or natural language ("review this SwiftUI view").

## Baseline this skill writes for

- Pure SwiftUI first — only drop to UIKit when the user explicitly needs it.
- Concurrency is structured async/await; no GCD unless there's a concrete reason.
- New dependencies are a conversation, not a default — ask before adding one.
- File hygiene: one declaration per file, grouped into folders by feature.
- Language/OS target follows the project; if unset, assume the current shipping
  Swift and SDK rather than legacy defaults.

## State management

Use `@Observable` (Observation framework), not `ObservableObject`/`@Published`.

❌ Legacy
```swift
final class CounterModel: ObservableObject {
    @Published var count = 0
}

struct CounterView: View {
    @StateObject private var model = CounterModel()
    var body: some View { Text("\(model.count)") }
}
```

✅ Modern
```swift
@Observable
final class CounterModel {
    var count = 0
}

struct CounterView: View {
    @State private var model = CounterModel()
    var body: some View { Text("\(model.count)") }
}
```

Rules:
- Own the model with `@State`. Pass it down plainly; use `@Bindable` only where you need
  two-way bindings to its properties.
- Use `@Environment` for app-wide models, not singletons.

## Modifiers and styling

- `foregroundStyle()` not `foregroundColor()`.
- `.background { ... }` / `.overlay { ... }` closure form, not deprecated overloads.
- Prefer `Grid`, `ViewThatFits`, and layout containers over manual `GeometryReader` math.

❌
```swift
Text("Hi").foregroundColor(.red)
```
✅
```swift
Text("Hi").foregroundStyle(.red)
```

## Navigation

Use `NavigationStack` with a typed path. `NavigationView` is deprecated.

❌
```swift
NavigationView {
    NavigationLink("Detail", destination: DetailView())
}
```
✅
```swift
NavigationStack(path: $path) {
    List(items) { item in
        NavigationLink(item.name, value: item.id)
    }
    .navigationDestination(for: Item.ID.self) { id in
        DetailView(id: id)
    }
}
```

## Performance

- Use `LazyVStack`/`LazyHStack` inside `ScrollView` for long content; plain `VStack`
  renders everything eagerly.
- Give `ForEach` stable identity (`Identifiable` or `id:`), never array indices for
  mutable collections.
- Keep `body` cheap. Move expensive work out of `body` into the model or `.task`.

❌ Index identity on a mutable list
```swift
ForEach(0..<items.count, id: \.self) { i in Row(items[i]) }
```
✅
```swift
ForEach(items) { item in Row(item) }
```

## Async work

Use `.task` (auto-cancelled on disappear), not `onAppear { Task { } }`.

✅
```swift
.task { await model.load() }
```

## Accessibility (always)

- Support Dynamic Type — avoid fixed font sizes; use semantic `.font(.body)` etc.
- Provide `.accessibilityLabel` for icon-only controls.
- Respect Reduce Motion for animations.

## Common mistakes checklist

- [ ] Using `ObservableObject`/`@Published` instead of `@Observable`.
- [ ] `foregroundColor` / `NavigationView` / other deprecated APIs.
- [ ] `VStack` where `LazyVStack` is needed.
- [ ] `ForEach` keyed by index on a mutable collection.
- [ ] Side effects or heavy compute in `body`.
- [ ] Icon-only buttons with no accessibility label.

## Output format (when reviewing)

Walk the code top to bottom. For each real problem give: the `file:line`, a one-line
statement of what's wrong, and a tight before → after snippet. Don't mention files that
are already fine. Close with the two or three fixes that matter most, in priority order.
