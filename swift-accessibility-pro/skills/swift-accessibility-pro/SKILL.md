---
name: swift-accessibility-pro
description: Use when making SwiftUI/UIKit apps accessible — VoiceOver labels and traits, Dynamic Type, color contrast, Reduce Motion, and accessibility testing.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Accessibility Pro

Make apps usable by everyone. Treat accessibility as a requirement, not an add-on.

## When to use

- Auditing or adding accessibility to SwiftUI/UIKit views.
- Fixing VoiceOver, Dynamic Type, or contrast issues.
- Preparing for accessibility review.

Trigger: `/swift-accessibility-pro`.

## Core principles

- Every interactive element needs a clear label and the right trait.
- Text must scale with Dynamic Type; never hard-code font sizes.
- Don't convey meaning with color alone.
- Respect user settings: Reduce Motion, Increase Contrast, Bold Text.

## VoiceOver labels

Icon-only controls are unlabeled to VoiceOver by default.

❌
```swift
Button { like() } label: { Image(systemName: "heart") }
```
✅
```swift
Button { like() } label: { Image(systemName: "heart") }
    .accessibilityLabel("Like")
```

Combine decorative + meaningful elements:
```swift
HStack { Image(systemName: "star.fill"); Text("4.8") }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Rating 4.8 out of 5")
```
Hide purely decorative images: `.accessibilityHidden(true)`.

## Traits

Tell VoiceOver what an element *is*.

✅
```swift
Text("Settings").accessibilityAddTraits(.isHeader)
Image("chart").accessibilityLabel("Sales up 12%").accessibilityRemoveTraits(.isImage)
```

## Dynamic Type

❌ Fixed size — won't scale
```swift
Text("Hello").font(.system(size: 17))
```
✅ Semantic style — scales
```swift
Text("Hello").font(.body)
```
For custom fonts use `.font(.custom("Inter", size: 17, relativeTo: .body))`. Test at the
largest accessibility sizes; use `ViewThatFits`/wrapping instead of truncation.

## Color & contrast

- Don't signal state with color only — add an icon, text, or shape.
- Meet WCAG contrast (4.5:1 for body text). Support `@Environment(\.colorSchemeContrast)`.

❌
```swift
Circle().fill(isOnline ? .green : .red)   // invisible to color-blind users
```
✅
```swift
Label(isOnline ? "Online" : "Offline",
      systemImage: isOnline ? "checkmark.circle" : "xmark.circle")
```

## Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
// ...
.animation(reduceMotion ? nil : .spring, value: state)
```

## Common mistakes checklist

- [ ] Icon-only buttons without `.accessibilityLabel`.
- [ ] Hard-coded font sizes that ignore Dynamic Type.
- [ ] State shown by color alone.
- [ ] Decorative images not hidden from VoiceOver.
- [ ] Headers without `.isHeader` trait.
- [ ] Animations that ignore Reduce Motion.
- [ ] Touch targets smaller than 44×44 pt.

## Output format (when reviewing)

Per issue: file:line, the barrier, before/after fix. Lead with blockers (unlabeled
controls, non-scaling text) before enhancements.
