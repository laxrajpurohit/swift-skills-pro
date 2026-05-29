---
name: swift-language-pro
description: Use when writing or reviewing core Swift — choosing value vs reference types, handling optionals, error handling, generics, protocols, and following Swift API design guidelines.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Language Pro

Write idiomatic, safe, modern Swift. Follow Apple's API Design Guidelines.

## When to use

- Writing or reviewing non-UI Swift (models, services, utilities).
- Designing public APIs, naming, and type choices.
- Cleaning up optional handling, error handling, or generics.

Trigger: `/swift-language-pro`.

## Core principles

- Prefer value types (`struct`/`enum`) by default; use `class` only for identity or
  reference semantics.
- Make illegal states unrepresentable with enums and non-optional types.
- Throw typed errors; don't return sentinel values or booleans for failure.
- Name for clarity at the call site, not the definition.

## Value vs reference

❌
```swift
class Point { var x = 0.0; var y = 0.0 }   // accidental shared mutation
```
✅
```swift
struct Point { var x = 0.0; var y = 0.0 }
```

## Model with enums, kill optionals

❌ Two bools that allow impossible states
```swift
struct State { var isLoading: Bool; var error: Error? }   // loading + error?
```
✅
```swift
enum LoadState<Value> { case idle, loading, loaded(Value), failed(Error) }
```

## Optionals

- Unwrap with `if let` / `guard let`; avoid force-unwrap `!` outside tests.
- `guard` for early exit, keeping the happy path unindented.

❌
```swift
func name(_ u: User?) -> String { return u!.name }
```
✅
```swift
func name(_ u: User?) -> String {
    guard let u else { return "Guest" }
    return u.name
}
```

## Error handling

❌ Boolean failure
```swift
func save() -> Bool
```
✅
```swift
enum SaveError: Error { case diskFull, notAuthorized }
func save() throws    // call sites use try/catch; errors carry meaning
```

## API design (naming)

- Read at the call site like a phrase. Include the noun a method acts on.
- Omit needless words; drop type names from labels.

❌
```swift
func insertObject(_ obj: Element, atIndex i: Int)
list.insertObject(x, atIndex: 0)
```
✅
```swift
func insert(_ element: Element, at index: Int)
list.insert(x, at: 0)
```

## Generics & protocols

- Constrain generics with `where`; prefer protocols with associated types over `Any`.
- Use protocol extensions for default behavior; don't reach for class inheritance.

✅
```swift
func max<C: Collection>(of items: C) -> C.Element? where C.Element: Comparable {
    items.max()
}
```

## Common mistakes checklist

- [ ] `class` where a `struct` would do.
- [ ] Optional/bool combos that allow impossible states (use an enum).
- [ ] Force-unwrap `!` in app code.
- [ ] Returning `Bool`/`nil` for failures instead of `throws`.
- [ ] Method names that repeat type info or don't read at the call site.
- [ ] `Any`/type-erasure where a generic constraint fits.

## Output format (when reviewing)

Per issue: file:line, the guideline violated, before/after. Lead with safety
(force-unwraps, impossible states) before style.
