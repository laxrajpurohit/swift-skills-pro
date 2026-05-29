---
name: swift-architecture-pro
description: Use when structuring an iOS app — feature modularization, MVVM with @Observable, dependency injection, navigation routing, and layering for testability.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Architecture Pro

Structure apps so features are isolated, testable, and easy to reason about.

## When to use

- Setting up or refactoring app architecture.
- Deciding module/folder boundaries, DI, or navigation.
- Untangling massive views or view models.

Trigger: `/swift-architecture-pro`.

## Core principles

- Organize by feature, not by technical layer.
- Views are dumb; logic lives in `@Observable` models.
- Depend on protocols, inject implementations — no singletons reached from inside views.
- Keep types small and single-purpose; a growing file signals split needed.

## Folder layout — by feature

❌ By layer
```
Views/  Models/  ViewModels/  Services/   // every feature scattered across all four
```
✅ By feature
```
Features/
  Feed/      FeedView.swift  FeedModel.swift  FeedService.swift
  Profile/   ProfileView.swift ProfileModel.swift
Core/        Networking/  Persistence/  DesignSystem/
```

## MVVM with @Observable

```swift
@MainActor @Observable
final class FeedModel {
    private(set) var posts: [Post] = []
    private let service: FeedServing
    init(service: FeedServing) { self.service = service }
    func load() async { posts = (try? await service.posts()) ?? [] }
}

struct FeedView: View {
    @State private var model: FeedModel
    var body: some View {
        List(model.posts) { PostRow($0) }
            .task { await model.load() }
    }
}
```
View has no networking, no business rules — only presentation.

## Dependency injection

❌ Singleton reached from inside
```swift
final class FeedModel {
    func load() async { posts = await API.shared.posts() }   // untestable
}
```
✅ Protocol injected
```swift
protocol FeedServing { func posts() async throws -> [Post] }
final class FeedModel { init(service: FeedServing) { ... } }
// tests inject a fake; app injects the real one
```

## Navigation routing

Centralize a typed route; drive `NavigationStack` from it.

```swift
enum Route: Hashable { case detail(Post.ID), settings }

@Observable final class Router { var path: [Route] = [] }

NavigationStack(path: $router.path) {
    HomeView()
        .navigationDestination(for: Route.self) { route in
            switch route { case .detail(let id): DetailView(id: id)
                           case .settings: SettingsView() }
        }
}
```
Don't scatter `NavigationLink(destination:)` literals across the tree.

## Layering

`View → Model (@Observable) → Service (protocol) → Client (network/db)`. Dependencies
point downward only; lower layers never import UI.

## Common mistakes checklist

- [ ] Folders by layer instead of by feature.
- [ ] Networking/business logic inside a `View`.
- [ ] Singletons reached from inside models (inject protocols instead).
- [ ] Navigation destinations scattered instead of a typed router.
- [ ] God objects — one model/view doing many features.
- [ ] Lower layers importing SwiftUI/UIKit.

## Output format (when reviewing)

Per issue: file:line, the boundary violated, suggested split. Lead with testability
blockers (hard-wired singletons, logic in views).
