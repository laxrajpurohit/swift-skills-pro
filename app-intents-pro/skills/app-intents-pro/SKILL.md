---
name: app-intents-pro
description: Use when adding App Intents — exposing app actions to Siri, Shortcuts, and Spotlight with AppIntent, parameters, AppEntity, and App Shortcuts.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# App Intents Pro

Expose app actions to the system: Siri, Shortcuts, Spotlight, widgets, and controls.

## When to use

- Adding `AppIntent`s for app actions.
- Modeling `AppEntity` types for parameters/results.
- Registering `AppShortcuts` for zero-setup Siri phrases.

Trigger: `/app-intents-pro`.

## Core principles

- An intent is a small, single-purpose action with typed parameters.
- Keep business logic in your model layer; the intent is a thin adapter.
- Provide `AppShortcuts` so users get Siri phrases without manual setup.
- Return useful results/snippets, not just success.

## A basic intent

```swift
import AppIntents

struct AddTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Task"
    static let description = IntentDescription("Creates a new task.")

    @Parameter(title: "Title") var taskTitle: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await TaskStore.shared.add(title: taskTitle)
        return .result(dialog: "Added “\(taskTitle)”.")
    }
}
```

- `title`/`description` are required and user-visible.
- `perform()` is `async throws` — call your real model, don't duplicate logic.

## Parameters

❌ Untyped, no prompt
```swift
@Parameter var value: String   // Siri can't elicit it well
```
✅
```swift
@Parameter(title: "Due date") var dueDate: Date
@Parameter(title: "Priority") var priority: Priority   // an AppEnum
```

`AppEnum` for fixed choices:
```swift
enum Priority: String, AppEnum {
    case low, normal, high
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Priority"
    static let caseDisplayRepresentations: [Priority: DisplayRepresentation] =
        [.low: "Low", .normal: "Normal", .high: "High"]
}
```

## AppEntity (model objects as parameters/results)

```swift
struct TaskEntity: AppEntity, Identifiable {
    let id: UUID
    let title: String
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Task"
    var displayRepresentation: DisplayRepresentation { .init(title: "\(title)") }
    static var defaultQuery = TaskQuery()
}

struct TaskQuery: EntityQuery {
    func entities(for ids: [UUID]) async throws -> [TaskEntity] { /* fetch */ }
    func suggestedEntities() async throws -> [TaskEntity] { /* recents */ }
}
```

## App Shortcuts (zero-config Siri)

```swift
struct TasksShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddTaskIntent(),
                    phrases: ["Add a task in \(.applicationName)"],
                    shortTitle: "Add Task",
                    systemImageName: "plus.circle")
    }
}
```
Always include `\(.applicationName)` in at least one phrase.

## Common mistakes checklist

- [ ] Business logic copied into `perform()` instead of calling the model.
- [ ] Untyped `String` parameters where `Date`/`AppEnum`/`AppEntity` fit.
- [ ] No `AppShortcutsProvider`, so users get no Siri phrases.
- [ ] Phrases missing `\(.applicationName)`.
- [ ] Returning bare success with no dialog/snippet.
- [ ] `EntityQuery` without `suggestedEntities()`.

## Output format (when reviewing)

Per issue: file:line, rule, before/after. Flag intents that bypass the model layer first.
