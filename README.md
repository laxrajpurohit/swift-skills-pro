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
