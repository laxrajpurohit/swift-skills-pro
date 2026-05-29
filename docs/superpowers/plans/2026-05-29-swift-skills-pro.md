# swift-skills-pro Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and publish an original, installable Claude Code plugin marketplace of high-quality Swift/Apple agent skills (4 skills in first release).

**Architecture:** A single GitHub repo doubling as a Claude Code plugin marketplace. Root `.claude-plugin/marketplace.json` lists each skill as a plugin whose `source` points to a sibling folder containing a `SKILL.md`. No build step. Distribution via `/plugin marketplace add`, `npx skills`, or manual copy.

**Tech Stack:** Markdown (SKILL.md, docs), JSON (marketplace manifest), Git/GitHub, `gh` CLI.

**Working directory:** `/Users/lax/swift-skills-pro` (already `git init`'d).

---

## File Structure

```
swift-skills-pro/
├── .claude-plugin/
│   └── marketplace.json          # lists 4 skills as plugins
├── swiftui-pro/SKILL.md          # modern SwiftUI skill
├── swift-concurrency-pro/SKILL.md# async/await, actors, Sendable
├── swiftdata-pro/SKILL.md        # SwiftData modeling/queries/migration
├── swift-testing-pro/SKILL.md    # Swift Testing framework
├── README.md                     # install + skill table + attribution + safety
├── LICENSE                       # MIT, 2026, Lax Rajpurohit
├── CODE_OF_CONDUCT.md            # Contributor Covenant short form
└── .gitignore                    # macOS junk
```

Responsibilities: each `SKILL.md` is one self-contained skill (frontmatter + body). `marketplace.json` is the only coupling point — it must list every skill folder. README is the human entry point.

---

## Task 1: Repo scaffold (license, code of conduct, gitignore)

**Files:**
- Create: `/Users/lax/swift-skills-pro/.gitignore`
- Create: `/Users/lax/swift-skills-pro/LICENSE`
- Create: `/Users/lax/swift-skills-pro/CODE_OF_CONDUCT.md`

- [ ] **Step 1: Write `.gitignore`**

```
.DS_Store
*.swp
.idea/
.vscode/
```

- [ ] **Step 2: Write `LICENSE` (MIT)**

```
MIT License

Copyright (c) 2026 Lax Rajpurohit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 3: Write `CODE_OF_CONDUCT.md`**

```markdown
# Code of Conduct

## Our Pledge

We pledge to make participation in this project a harassment-free experience for
everyone, regardless of age, body size, disability, ethnicity, gender identity and
expression, level of experience, nationality, personal appearance, race, religion, or
sexual identity and orientation.

## Our Standards

Examples of behavior that contributes to a positive environment:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

Examples of unacceptable behavior:

- Harassment of any kind
- Trolling, insulting/derogatory comments, personal or political attacks
- Publishing others' private information without permission

## Enforcement

Instances of abusive or otherwise unacceptable behavior may be reported to the project
maintainer. All complaints will be reviewed and investigated promptly and fairly.

This Code of Conduct is adapted from the Contributor Covenant, version 2.1.
```

- [ ] **Step 4: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add .gitignore LICENSE CODE_OF_CONDUCT.md
git commit -m "Add license, code of conduct, gitignore"
```

---

## Task 2: Marketplace manifest

**Files:**
- Create: `/Users/lax/swift-skills-pro/.claude-plugin/marketplace.json`

- [ ] **Step 1: Write `marketplace.json`**

```json
{
  "name": "swift-skills-pro",
  "owner": { "name": "Lax Rajpurohit" },
  "metadata": {
    "description": "Modern, original agent skills for Swift and Apple-platform development",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "swiftui-pro",
      "source": "./swiftui-pro",
      "description": "Modern SwiftUI: @Observable, NavigationStack, layout, performance, and anti-patterns.",
      "version": "1.0.0",
      "author": { "name": "Lax Rajpurohit" },
      "homepage": "https://github.com/laxrajpurohit/swift-skills-pro",
      "repository": "https://github.com/laxrajpurohit/swift-skills-pro",
      "license": "MIT",
      "keywords": ["swiftui", "swift", "ios", "apple"]
    },
    {
      "name": "swift-concurrency-pro",
      "source": "./swift-concurrency-pro",
      "description": "async/await, actors, Sendable, and strict concurrency for Swift 6.",
      "version": "1.0.0",
      "author": { "name": "Lax Rajpurohit" },
      "homepage": "https://github.com/laxrajpurohit/swift-skills-pro",
      "repository": "https://github.com/laxrajpurohit/swift-skills-pro",
      "license": "MIT",
      "keywords": ["swift", "concurrency", "async", "actors", "sendable"]
    },
    {
      "name": "swiftdata-pro",
      "source": "./swiftdata-pro",
      "description": "SwiftData modeling, queries, migrations, and CloudKit sync.",
      "version": "1.0.0",
      "author": { "name": "Lax Rajpurohit" },
      "homepage": "https://github.com/laxrajpurohit/swift-skills-pro",
      "repository": "https://github.com/laxrajpurohit/swift-skills-pro",
      "license": "MIT",
      "keywords": ["swiftdata", "swift", "persistence", "cloudkit"]
    },
    {
      "name": "swift-testing-pro",
      "source": "./swift-testing-pro",
      "description": "Swift Testing framework: @Test, #expect, traits, parameterized tests, XCTest migration.",
      "version": "1.0.0",
      "author": { "name": "Lax Rajpurohit" },
      "homepage": "https://github.com/laxrajpurohit/swift-skills-pro",
      "repository": "https://github.com/laxrajpurohit/swift-skills-pro",
      "license": "MIT",
      "keywords": ["swift", "testing", "swift-testing", "xctest"]
    }
  ]
}
```

- [ ] **Step 2: Validate JSON parses**

Run: `python3 -c "import json; json.load(open('/Users/lax/swift-skills-pro/.claude-plugin/marketplace.json')); print('valid')"`
Expected: `valid`

- [ ] **Step 3: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add .claude-plugin/marketplace.json
git commit -m "Add plugin marketplace manifest"
```

---

## Task 3: swiftui-pro skill

**Files:**
- Create: `/Users/lax/swift-skills-pro/swiftui-pro/SKILL.md`

- [ ] **Step 1: Write `swiftui-pro/SKILL.md`**

````markdown
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

## Core assumptions

- iOS 26 is the default deployment target.
- Swift 6.2+, modern Swift concurrency.
- Prefer SwiftUI; avoid UIKit unless asked.
- One type per file; folder layout by feature.
- No third-party frameworks without asking.

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

Group by file. Per issue: file:line, rule name, brief before/after fix. Skip clean files.
End with a prioritized summary.
````

- [ ] **Step 2: Verify frontmatter present**

Run: `head -8 /Users/lax/swift-skills-pro/swiftui-pro/SKILL.md`
Expected: shows `name: swiftui-pro` and `description:` lines.

- [ ] **Step 3: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add swiftui-pro/SKILL.md
git commit -m "Add swiftui-pro skill"
```

---

## Task 4: swift-concurrency-pro skill

**Files:**
- Create: `/Users/lax/swift-skills-pro/swift-concurrency-pro/SKILL.md`

- [ ] **Step 1: Write `swift-concurrency-pro/SKILL.md`**

````markdown
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
````

- [ ] **Step 2: Verify frontmatter present**

Run: `head -8 /Users/lax/swift-skills-pro/swift-concurrency-pro/SKILL.md`
Expected: shows `name: swift-concurrency-pro`.

- [ ] **Step 3: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add swift-concurrency-pro/SKILL.md
git commit -m "Add swift-concurrency-pro skill"
```

---

## Task 5: swiftdata-pro skill

**Files:**
- Create: `/Users/lax/swift-skills-pro/swiftdata-pro/SKILL.md`

- [ ] **Step 1: Write `swiftdata-pro/SKILL.md`**

````markdown
---
name: swiftdata-pro
description: Use when modeling data with SwiftData (@Model), writing @Query, configuring ModelContainer, performing migrations, or enabling CloudKit sync on iOS 17+.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# SwiftData Pro

Model, query, and persist data with SwiftData correctly and efficiently.

## When to use

- Defining `@Model` types and relationships.
- Writing `@Query` / fetching in views.
- Setting up `ModelContainer`, migrations, or CloudKit sync.

Trigger: `/swiftdata-pro`.

## Core principles

- `@Model` classes are reference types managed by a `ModelContext`.
- Inject the container at the app root with `.modelContainer(for:)`.
- Read in views with `@Query`; write through the `modelContext`.
- Keep the main-actor context for UI; use a background `ModelContext` for bulk work.

## Modeling

```swift
@Model
final class Trip {
    var name: String
    var startDate: Date
    @Relationship(deleteRule: .cascade) var stops: [Stop] = []

    init(name: String, startDate: Date) {
        self.name = name
        self.startDate = startDate
    }
}
```

- Set an explicit `deleteRule` on relationships — don't rely on defaults for ownership.
- Use `@Attribute(.unique)` for natural keys.
- Mark large blobs `@Attribute(.externalStorage)`.

❌ No delete rule on an owning relationship
```swift
var stops: [Stop] = []   // orphans Stop rows when a Trip is deleted
```
✅
```swift
@Relationship(deleteRule: .cascade) var stops: [Stop] = []
```

## Container setup

```swift
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: Trip.self)
    }
}
```

## Querying

Use `@Query` with sort/filter in the view; don't fetch-all then filter in Swift.

❌
```swift
@Query private var trips: [Trip]
var upcoming: [Trip] { trips.filter { $0.startDate > .now } }   // loads everything
```
✅
```swift
@Query(filter: #Predicate<Trip> { $0.startDate > Date.now },
       sort: \Trip.startDate)
private var upcoming: [Trip]
```

## Writing

```swift
@Environment(\.modelContext) private var context

func add(_ trip: Trip) {
    context.insert(trip)
    // SwiftData autosaves; call try? context.save() only when you need it now.
}
```
Delete with `context.delete(trip)`.

## Background work

For imports/bulk writes, use a separate context off the main actor and save in batches:
```swift
let context = ModelContext(container)
for row in rows { context.insert(Item(row)) }
try context.save()
```
Don't do thousands of inserts on the main-actor context — it blocks the UI.

## Migrations

- Lightweight changes (adding optional properties) migrate automatically.
- Breaking changes need a `SchemaMigrationPlan` with versioned schemas and migration
  stages. Define `VersionedSchema` types; never silently mutate a shipped model.

## CloudKit sync

- Every property must be optional or have a default; relationships must be optional.
- No `@Attribute(.unique)` (CloudKit can't enforce it).
- Configure with a `ModelConfiguration` using a CloudKit container identifier.

❌ (breaks CloudKit)
```swift
@Attribute(.unique) var code: String
```
✅
```swift
var code: String = ""
```

## Common mistakes checklist

- [ ] Missing `deleteRule` on owning relationships.
- [ ] Filtering fetched arrays in Swift instead of `#Predicate` in `@Query`.
- [ ] Bulk inserts on the main-actor context.
- [ ] `.unique` or non-optional properties on a CloudKit-synced model.
- [ ] Breaking schema change with no migration plan.

## Output format (when reviewing)

Per issue: file:line, rule, before/after. Lead with data-loss / migration risks.
````

- [ ] **Step 2: Verify frontmatter present**

Run: `head -8 /Users/lax/swift-skills-pro/swiftdata-pro/SKILL.md`
Expected: shows `name: swiftdata-pro`.

- [ ] **Step 3: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add swiftdata-pro/SKILL.md
git commit -m "Add swiftdata-pro skill"
```

---

## Task 6: swift-testing-pro skill

**Files:**
- Create: `/Users/lax/swift-skills-pro/swift-testing-pro/SKILL.md`

- [ ] **Step 1: Write `swift-testing-pro/SKILL.md`**

````markdown
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
````

- [ ] **Step 2: Verify frontmatter present**

Run: `head -8 /Users/lax/swift-skills-pro/swift-testing-pro/SKILL.md`
Expected: shows `name: swift-testing-pro`.

- [ ] **Step 3: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add swift-testing-pro/SKILL.md
git commit -m "Add swift-testing-pro skill"
```

---

## Task 7: README

**Files:**
- Create: `/Users/lax/swift-skills-pro/README.md`

- [ ] **Step 1: Write `README.md`**

````markdown
# Swift Skills Pro

Modern, original agent skills for Swift and Apple-platform development. Use them with
Claude Code, Codex, Cursor, Windsurf, and other AI coding tools to write better SwiftUI,
Swift concurrency, SwiftData, and tests.

Every skill here is written from scratch, targets **Swift 6 / iOS 26**, and pairs each
rule with ❌ wrong / ✅ right examples plus a mistakes checklist.

## ⚠️ Safety note

These are agent skills that instruct AI tools how to write your code. Read a skill before
you install it and make sure you trust it. You are responsible for the code your tools
produce.

## Skills

| Skill | What it does |
|-------|--------------|
| `swiftui-pro` | Modern SwiftUI — `@Observable`, `NavigationStack`, layout, performance, accessibility. |
| `swift-concurrency-pro` | async/await, actors, `Sendable`, Swift 6 strict concurrency. |
| `swiftdata-pro` | `@Model`, `@Query`, migrations, CloudKit sync. |
| `swift-testing-pro` | Swift Testing — `@Test`, `#expect`, traits, parameterized tests. |

## Install

### Claude Code (recommended)

```
/plugin marketplace add laxrajpurohit/swift-skills-pro
/plugin install swiftui-pro@swift-skills-pro
```

Install any of the four skills the same way (`swift-concurrency-pro@swift-skills-pro`,
etc.). Trigger an installed skill with its slash command, e.g. `/swiftui-pro`.

### npx (cross-tool)

```
npx skills add https://github.com/laxrajpurohit/swift-skills-pro --skill swiftui-pro
```

Requires Node.js (`brew install node`).

### Manual

Clone the repo and copy a skill folder into `~/.claude/skills/`:

```
git clone https://github.com/laxrajpurohit/swift-skills-pro
cp -R swift-skills-pro/swiftui-pro ~/.claude/skills/swiftui-pro
```

## Usage

| Skill | Trigger |
|-------|---------|
| swiftui-pro | `/swiftui-pro` |
| swift-concurrency-pro | `/swift-concurrency-pro` |
| swiftdata-pro | `/swiftdata-pro` |
| swift-testing-pro | `/swift-testing-pro` |

Natural-language prompts work too ("review this SwiftUI view").

## Acknowledgements

Inspired by the Swift agent-skills community, including Paul Hudson's
[swift-agent-skills](https://github.com/twostraws/swift-agent-skills) directory. All
content in this repository is original; no skill text was copied from other authors.

## Contributing

Contributions welcome. Please ensure:

- Content is written by a human, not generated wholesale by AI.
- No plagiarism — write your own material.
- An App-Store-compatible license (MIT, Apache 2, BSD, ISC).
- You follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2026 Lax Rajpurohit.
````

- [ ] **Step 2: Commit**

```bash
cd /Users/lax/swift-skills-pro
git add README.md
git commit -m "Add README with install instructions and skill list"
```

---

## Task 8: Publish to GitHub

**Files:** none (git/gh operations).

- [ ] **Step 1: Confirm `gh` is authenticated**

Run: `gh auth status`
Expected: shows logged-in account. If not, stop and ask the user to run `gh auth login`.

- [ ] **Step 2: Create the GitHub repo and push**

```bash
cd /Users/lax/swift-skills-pro
gh repo create swift-skills-pro --public --source=. --remote=origin \
  --description "Modern, original agent skills for Swift and Apple-platform development" --push
```
Expected: repo created at `https://github.com/laxrajpurohit/swift-skills-pro`, default branch pushed.

- [ ] **Step 3: Verify remote**

Run: `git remote -v && git ls-remote --heads origin`
Expected: `origin` points to the new repo; a branch head is listed.

---

## Task 9: Verify install end-to-end

**Files:** none.

- [ ] **Step 1: Re-validate manifest from the published repo**

Run: `python3 -c "import json,urllib.request; json.load(urllib.request.urlopen('https://raw.githubusercontent.com/laxrajpurohit/swift-skills-pro/main/.claude-plugin/marketplace.json')); print('manifest ok')"`
Expected: `manifest ok`

- [ ] **Step 2: Add the marketplace in Claude Code**

In a Claude Code session run: `/plugin marketplace add laxrajpurohit/swift-skills-pro`
Expected: marketplace added; 4 plugins listed (swiftui-pro, swift-concurrency-pro, swiftdata-pro, swift-testing-pro).

- [ ] **Step 3: Install one skill and confirm trigger**

Run: `/plugin install swiftui-pro@swift-skills-pro`
Then confirm `/swiftui-pro` appears as an available skill.
Expected: install succeeds and the skill triggers.

> Steps 2–3 are user-run in an interactive Claude Code session (the agent cannot self-install plugins). Report the manifest check (Step 1) as the automated verification and hand Steps 2–3 to the user.

---

## Notes on "better than the originals"

- One marketplace bundles four coordinated skills (most community repos ship a single skill).
- Uniform structure: every skill has triggers, ❌/✅ pairs, a mistakes checklist, and a review output format.
- Consistent modern baseline: Swift 6 / iOS 26 across all four.
- Original content with explicit attribution and a no-plagiarism contributing policy.
