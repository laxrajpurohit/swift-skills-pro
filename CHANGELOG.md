# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-10-13

### Added

- **swift-guardrails-pro** — Ratcheted SwiftLint, copy-paste detection (jscpd), and an
  Xcode `project.pbxproj` malware scan, checked on changed lines only. As a Claude Code
  plugin or via `npx swift-skills-cli install`, it runs automatically after every Swift
  edit and before every `git commit` in Claude Code, Cursor, Codex, and Windsurf, with no
  per-project setup.

### Changed

- `swift-skills-cli` installs and uninstalls the whole skill folder, not just `SKILL.md`,
  so skills can ship scripts and templates.
- `swift-skills-cli install` registers agent hooks for skills that ship them, merging
  into existing hook configs; `--no-hooks` skips it, `uninstall` removes them.

## [1.0.0] — 2026-06-06

### Added

- **swiftui-pro** — Modern SwiftUI: `@Observable`, `NavigationStack`, layout, performance, accessibility.
- **swift-concurrency-pro** — async/await, actors, `Sendable`, Swift 6 strict concurrency.
- **swiftdata-pro** — `@Model`, `@Query`, migrations, CloudKit sync.
- **core-data-pro** — Core Data modeling, background contexts, fetch requests, migration.
- **swift-language-pro** — Idiomatic Swift: value types, optionals, error handling, generics.
- **swift-testing-pro** — Swift Testing: `@Test`, `#expect`, traits, parameterized tests.
- **swift-architecture-pro** — Feature modularization, MVVM, dependency injection, routing.
- **swift-performance-pro** — Instruments, render cost, memory/retain cycles, launch time.
- **swift-accessibility-pro** — VoiceOver, Dynamic Type, contrast, Reduce Motion, testing.
- **app-intents-pro** — App Intents: Siri, Shortcuts, Spotlight, `AppEntity`.
- **swift-security-pro** — Keychain, Data Protection, ATS/TLS, secrets, biometrics.
- Marketplace configuration with all 11 skills.
- Full documentation with install guides for Claude Code, npx, and manual setup.

[1.1.0]: https://github.com/laxrajpurohit/swift-skills-pro/releases/tag/v1.1.0
[1.0.0]: https://github.com/laxrajpurohit/swift-skills-pro/releases/tag/v1.0.0
