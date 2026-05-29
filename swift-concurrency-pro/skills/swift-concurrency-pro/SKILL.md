---
name: swift-concurrency-pro
description: Use when writing async/await code, fixing Sendable or data-race errors, enabling strict concurrency, using actors, or migrating from completion handlers in Swift 6.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Concurrency Pro

Write correct, data-race-free concurrent Swift. Target Swift 6 strict concurrency.

## When to use

- Writing or reviewing async/await code.
- Fixing `Sendable` / data-race / actor-isolation errors.
- Migrating completion-handler APIs to async.

Trigger: `/swift-concurrency-pro`.

## Core principles

- Swift 6 enforces data isolation at compile time. Treat every concurrency warning as a
  real bug, not noise.
- UI and view models are `@MainActor`. Background work runs off the main actor.
- Share mutable state through an `actor`, never a lock + global.
- Make types crossing concurrency boundaries `Sendable`.

## async/await over completion handlers

❌
```swift
func loadUser(completion: @escaping (Result<User, Error>) -> Void) { ... }
```
✅
```swift
func loadUser() async throws -> User { ... }
```

Wrap legacy callbacks with continuations:
```swift
func loadUser() async throws -> User {
    try await withCheckedThrowingContinuation { cont in
        legacyLoad { result in cont.resume(with: result) }
    }
}
```
Resume a continuation exactly once — never zero, never twice.

## Actors for shared mutable state

❌ Lock around shared dictionary
```swift
final class Cache {
    private var store: [String: Data] = [:]
    private let lock = NSLock()
    func set(_ d: Data, _ k: String) { lock.lock(); store[k] = d; lock.unlock() }
}
```
✅
```swift
actor Cache {
    private var store: [String: Data] = [:]
    func set(_ d: Data, for k: String) { store[k] = d }
    func get(_ k: String) -> Data? { store[k] }
}
```
Access is `await cache.set(...)`. Don't expose `var` actor state directly across actors.

## @MainActor for UI

```swift
@MainActor
@Observable
final class FeedModel {
    var posts: [Post] = []
    func refresh() async {
        let fetched = await api.posts()   // api hops off main as needed
        posts = fetched                   // back on main, safe
    }
}
```
Don't sprinkle `DispatchQueue.main.async` — annotate with `@MainActor` instead.

## Sendable

- `struct`/`enum` of `Sendable` members → automatically `Sendable`.
- Final classes with immutable state → mark `Sendable`.
- Mutable classes shared across actors → make it an `actor`, or isolate it.

❌
```swift
class Settings { var theme = "light" }   // shared across tasks → data race
```
✅
```swift
actor Settings { var theme = "light" }
// or, if truly immutable:
struct Settings: Sendable { let theme: String }
```

## Structured concurrency

Use `async let` / `TaskGroup` for parallel work; they auto-cancel and propagate errors.

✅
```swift
async let a = api.profile()
async let b = api.feed()
let (profile, feed) = try await (a, b)
```

Avoid unstructured `Task { }` for work tied to a view's lifetime — use `.task` so it
cancels on disappear.

## Common mistakes checklist

- [ ] Resuming a continuation zero or multiple times.
- [ ] `DispatchQueue.main.async` instead of `@MainActor`.
- [ ] Lock-guarded shared state that should be an `actor`.
- [ ] Non-`Sendable` type sent across a concurrency boundary.
- [ ] Detached `Task {}` for view-scoped work (won't cancel).
- [ ] Suppressing concurrency warnings instead of fixing isolation.

## Output format (when reviewing)

Per issue: file:line, the isolation/Sendable rule violated, before/after fix.
End with the highest-risk data races first.
