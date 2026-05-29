---
name: core-data-pro
description: Use when working with Core Data — modeling entities, NSPersistentContainer setup, background contexts, fetch requests, batch operations, and migrations.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Core Data Pro

Use Core Data correctly: safe contexts, efficient fetches, clean migrations. (For new
apps, also consider SwiftData — see `swiftdata-pro`.)

## When to use

- Existing Core Data stacks, or apps needing fine-grained control.
- Fixing threading crashes, slow fetches, or migration failures.

Trigger: `/core-data-pro`.

## Core principles

- The view context is main-queue only; never touch it off the main thread.
- Do writes/imports on a background context, then merge.
- `NSManagedObject`s belong to their context — don't pass them across threads, pass IDs.
- Fetch only what you need (predicates, limits, batching).

## Stack setup

```swift
let container = NSPersistentContainer(name: "Model")
container.loadPersistentStores { _, error in
    if let error { fatalError("Store load failed: \(error)") }
}
container.viewContext.automaticallyMergesChangesFromParent = true
```

## Threading

❌ Background work on the view context (crashes / corruption)
```swift
DispatchQueue.global().async {
    let obj = Item(context: container.viewContext)   // wrong queue
}
```
✅ Background context with `perform`
```swift
container.performBackgroundTask { context in
    let obj = Item(context: context)
    obj.title = "New"
    try? context.save()   // merges into viewContext automatically
}
```

Pass object IDs across contexts, not objects:
```swift
let id = obj.objectID
container.performBackgroundTask { ctx in
    let bgObj = ctx.object(with: id)
}
```

## Fetching efficiently

❌ Fetch everything, filter in Swift
```swift
let all = try context.fetch(Item.fetchRequest())
let recent = all.filter { $0.date > cutoff }     // loads the whole table
```
✅ Predicate + sort + limit in the request
```swift
let req = Item.fetchRequest()
req.predicate = NSPredicate(format: "date > %@", cutoff as NSDate)
req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
req.fetchLimit = 50
let recent = try context.fetch(req)
```
Use `fetchBatchSize` for large lists; `NSFetchedResultsController` (UIKit) or
`@FetchRequest` (SwiftUI) for table/list binding.

## Batch operations

For bulk delete/update, skip loading objects into memory:
```swift
let delete = NSBatchDeleteRequest(fetchRequest: Item.fetchRequest())
try context.execute(delete)
// then merge changes into viewContext
```

## Migrations

- Lightweight migration handles simple schema changes — keep model versions and set
  `shouldInferMappingModelAutomatically = true`.
- Complex changes need a mapping model / custom `NSEntityMigrationPolicy`. Never edit a
  shipped model version in place; add a new version.

## Common mistakes checklist

- [ ] Accessing the view context off the main thread.
- [ ] Creating/editing objects on a context's wrong queue (no `perform`).
- [ ] Passing `NSManagedObject`s across threads instead of `objectID`.
- [ ] Fetch-all then filter in Swift instead of an `NSPredicate`.
- [ ] No `fetchLimit`/`fetchBatchSize` on large fetches.
- [ ] Looping deletes instead of `NSBatchDeleteRequest`.
- [ ] Editing a shipped model version instead of adding a new one.

## Output format (when reviewing)

Per issue: file:line, rule, before/after. Lead with threading violations (crash risk) and
migration hazards.
