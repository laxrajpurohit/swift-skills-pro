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
