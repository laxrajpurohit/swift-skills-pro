# swift-skills-pro — Design Spec

**Date:** 2026-05-29
**Author:** laxrajpurohit
**Status:** Approved for planning

## Goal

Build an original, high-quality, installable collection of Claude Code agent skills for
Swift and Apple-platform development. Distributed as a Claude Code plugin marketplace
(same distribution model as `twostraws/SwiftUI-Agent-Skill`) so any user can install with
one command.

Positioning: **better than existing single-topic skills** — not a copy. Differentiators:

- **Bundled**: one repo, one marketplace, multiple skills (others ship one skill each).
- **Modern**: Swift 6, strict concurrency, iOS 26 / SwiftUI current APIs.
- **Practical**: every skill includes real code examples plus explicit anti-patterns
  (wrong vs right), and clear trigger/usage instructions.
- All content is original writing. No copy-paste from other authors. Attribution +
  safety note in README.

## Distribution / Install model

Repo doubles as a Claude Code plugin marketplace. Three install paths documented:

1. Claude Code:
   - `/plugin marketplace add laxrajpurohit/swift-skills-pro`
   - `/plugin install <skill>@swift-skills-pro`
2. npx (cross-tool): `npx skills add https://github.com/laxrajpurohit/swift-skills-pro --skill <name>`
3. Manual: clone, copy skill folder into `~/.claude/skills/`.

## Repo structure

```
swift-skills-pro/
├── .claude-plugin/
│   └── marketplace.json        # lists all skills as installable plugins
├── swiftui-pro/
│   ├── .claude-plugin/plugin.json
│   └── SKILL.md
├── swift-concurrency-pro/
│   ├── .claude-plugin/plugin.json
│   └── SKILL.md
├── swiftdata-pro/
│   ├── .claude-plugin/plugin.json
│   └── SKILL.md
├── swift-testing-pro/
│   ├── .claude-plugin/plugin.json
│   └── SKILL.md
├── README.md
├── LICENSE                     # MIT
├── CODE_OF_CONDUCT.md
└── .gitignore
```

Note: exact plugin manifest layout (single `marketplace.json` vs per-skill `plugin.json`)
to be confirmed against current Claude Code plugin schema during implementation, mirroring
the `twostraws/SwiftUI-Agent-Skill` working example.

## Skills (first release — 4)

Each skill is a self-contained unit: one purpose, a SKILL.md with YAML frontmatter
(`name`, `description`), trigger instructions, and body content.

1. **swiftui-pro** — modern SwiftUI: @Observable, NavigationStack, layout, performance,
   common anti-patterns. Trigger: `/swiftui-pro`.
2. **swift-concurrency-pro** — async/await, actors, Sendable, strict concurrency,
   migration from completion handlers. Trigger: `/swift-concurrency-pro`.
3. **swiftdata-pro** — SwiftData modeling, queries, migrations, CloudKit sync, pitfalls.
   Trigger: `/swiftdata-pro`.
4. **swift-testing-pro** — Swift Testing framework (`@Test`, `#expect`, traits,
   parameterized tests), migration from XCTest. Trigger: `/swift-testing-pro`.

### SKILL.md content template (per skill)

- Frontmatter: `name`, `description` (trigger-focused, one line).
- When to use / triggers.
- Core principles (concise, modern best practice).
- Code examples: **anti-pattern (❌) vs correct (✅)** pairs.
- Common mistakes checklist.
- References to official Apple docs where useful.

## Out of scope (first release)

- The remaining ~26 topic skills (accessibility, app intents, performance, security,
  etc.) — added incrementally later, each as a new folder + marketplace entry.
- Logo/assets (optional, can add later).
- CI / automated skill validation.

## Success criteria

- Repo pushed to `github.com/laxrajpurohit/swift-skills-pro`.
- `/plugin marketplace add laxrajpurohit/swift-skills-pro` works and lists 4 skills.
- Each skill installs and triggers correctly in Claude Code.
- README documents all 3 install methods, skill list, attribution, MIT license.
- All skill content original.

## Build sequence (high level)

1. Scaffold repo: `.claude-plugin/marketplace.json`, base files (README, LICENSE, CoC, .gitignore).
2. Write the 4 SKILL.md files + per-skill plugin.json.
3. Validate plugin manifest schema against a working reference.
4. README with install instructions + skill table + attribution/safety note.
5. Commit, create GitHub repo, push.
6. Verify install end-to-end.
