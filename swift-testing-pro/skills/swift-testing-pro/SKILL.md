---
name: swift-testing-pro
description: Use when writing tests with the Swift Testing framework (@Test, #expect, #require, traits, parameterized tests, @Suite) or migrating tests from XCTest.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Testing Pro

Write clear, fast tests with the Swift Testing framework. Prefer it over XCTest for new
code.

## When to use

- Writing new unit/integration tests.
- Migrating XCTest cases to Swift Testing.
- Adding parameterized or trait-gated tests.

Trigger: `/swift-testing-pro`.

## Core principles

- `@Test` functions, not `test`-prefixed `XCTestCase` methods.
- `#expect` for soft assertions; `#require` to stop the test on failure.
- Group with `@Suite` (struct/actor) — a fresh instance per test gives isolation.
- Use `async`/`throws` directly; no expectation-fulfillment dance.

## Basic test

❌ XCTest
```swift
import XCTest
final class MathTests: XCTestCase {
    func testAdd() { XCTAssertEqual(add(2, 3), 5) }
}
```
✅ Swift Testing
```swift
import Testing

@Test func add() {
    #expect(add(2, 3) == 5)
}
```

## #expect vs #require

- `#expect(x == y)` records a failure but continues.
- `try #require(value)` unwraps/asserts and **halts** the test if it fails — use before
  dereferencing.

✅
```swift
@Test func parsesUser() throws {
    let user = try #require(User(json: sample))   // stop if nil
    #expect(user.name == "Ada")
}
```

## Suites and state

```swift
@Suite struct CartTests {
    let cart = Cart()           // fresh per test — no shared state

    @Test func startsEmpty() { #expect(cart.items.isEmpty) }
    @Test func addsItem() {
        cart.add(.sample)
        #expect(cart.items.count == 1)
    }
}
```
Don't reuse mutable state across tests (no XCTest `setUp` shared singletons).

## Parameterized tests

Replace copy-pasted near-identical tests with `arguments:`.

❌
```swift
@Test func evenTwo() { #expect(isEven(2)) }
@Test func evenFour() { #expect(isEven(4)) }
```
✅
```swift
@Test(arguments: [2, 4, 100])
func even(_ n: Int) { #expect(isEven(n)) }
```
Cross-product with multiple `arguments:` collections; use `zip` for paired inputs.

## Async and errors

```swift
@Test func loadsFeed() async throws {
    let feed = try await api.feed()
    #expect(!feed.isEmpty)
}

@Test func throwsOnBadInput() {
    #expect(throws: ParseError.self) {
        try parse("")
    }
}
```

## Traits

- `.tags(.network)` to group/filter.
- `.enabled(if:)` / `.disabled("reason")` to gate.
- `.timeLimit(.minutes(1))` for runaway protection.
- `.bug("JIRA-123")` to link issues.

```swift
@Test(.disabled("flaky on CI — FIX-42"))
func flakyThing() { ... }
```
Prefer `.disabled("reason")` over commenting tests out — it stays visible and tracked.

## Common mistakes checklist

- [ ] Still subclassing `XCTestCase` for new tests.
- [ ] `#expect` before a force-unwrap that should be `try #require`.
- [ ] Shared mutable state across tests in a suite.
- [ ] Copy-pasted tests that should be `arguments:` parameterized.
- [ ] Commented-out tests instead of `.disabled("reason")`.
- [ ] `XCTestExpectation` where plain `async`/`await` works.

## Output format (when reviewing)

Per issue: file:line, rule, before/after. Flag missing coverage of error paths and edge
cases.
