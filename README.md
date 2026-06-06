<div align="center">

# 🦅 Swift Skills Pro

**Modern, original AI agent skills for Swift & Apple-platform development.**

Write better SwiftUI, Swift concurrency, SwiftData, and tests — straight from your AI
coding tool.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-11-orange.svg)](#-skills)
[![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)](https://swift.org)
[![iOS 26](https://img.shields.io/badge/iOS-26-000000?logo=apple&logoColor=white)](https://developer.apple.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-8A63D2.svg)](https://claude.com/claude-code)
[![GitHub stars](https://img.shields.io/github/stars/laxrajpurohit/swift-skills-pro?style=social)](https://github.com/laxrajpurohit/swift-skills-pro/stargazers)

</div>

---

Works with **Claude Code, Codex, Cursor, Windsurf**, and other Agent-Skills-compatible
tools. Every skill is **written from scratch**, targets **Swift 6 / iOS 26**, and pairs
each rule with `❌ wrong` / `✅ right` examples plus a mistakes checklist.

## 📚 Table of Contents

- [Why use this?](#-why-use-this)
- [Quick start](#-quick-start)
- [Skills](#-skills)
- [Install](#-install)
- [Usage](#-usage)
- [Safety](#-safety)
- [About](#-about)
- [Contributing](#-contributing)
- [License](#-license)

## 💡 Why use this?

Without these skills, an AI assistant gives generic answers and often reaches for outdated
APIs. With them installed, your tool writes and reviews Swift like a senior Apple-platform
engineer.

- **🎯 Modern by default** — always Swift 6 / iOS 26 patterns. No `foregroundColor`,
  `NavigationView`, or `ObservableObject` creeping back in.
- **🛡️ Catches real bugs** — retain cycles, data races, force-unwraps, deprecated APIs,
  missing accessibility, leaked secrets. Each skill ships a mistakes checklist.
- **🧩 11 topics, one install** — SwiftUI, concurrency, data, testing, architecture,
  performance, security, and more. Most skill repos cover just one.
- **⚡ Cheap on context** — a skill loads only when triggered (~80–90 tokens idle,
  ~1.3–1.4k on use). No bloat in every prompt.
- **🔍 Built-in code review** — every skill has a clear `file:line → problem → fix` output
  format, so PR and diff reviews get faster.
- **👥 Consistent across a team** — everyone's AI follows the same modern conventions.
- **🆓 Free & portable** — MIT licensed, works in Claude Code, Codex, Cursor, Windsurf.

> **In short:** safer, more modern, better Swift code from your AI — without memorising
> every best practice yourself.

## 🚀 Quick start

```bash
# In Claude Code:
/plugin marketplace add laxrajpurohit/swift-skills-pro
/plugin install swiftui-pro@swift-skills-pro

# Then trigger it:
/swiftui-pro
```

That's it — install any of the 11 skills the same way.

**Install all skills at once:**

```bash
/plugin marketplace add laxrajpurohit/swift-skills-pro
for skill in swiftui-pro swift-concurrency-pro swiftdata-pro core-data-pro swift-language-pro swift-testing-pro swift-architecture-pro swift-performance-pro swift-accessibility-pro app-intents-pro swift-security-pro; do
  /plugin install "$skill@swift-skills-pro"
done
```

## 🧩 Skills

### Core frameworks

| Skill | What it does |
|-------|--------------|
| `swiftui-pro` | Modern SwiftUI — `@Observable`, `NavigationStack`, layout, performance, accessibility. |
| `swift-concurrency-pro` | async/await, actors, `Sendable`, Swift 6 strict concurrency. |
| `swiftdata-pro` | `@Model`, `@Query`, migrations, CloudKit sync. |
| `core-data-pro` | Modeling, background contexts, fetch requests, batching, migration. |

### Language & quality

| Skill | What it does |
|-------|--------------|
| `swift-language-pro` | Idiomatic Swift — value types, optionals, error handling, generics, API design. |
| `swift-testing-pro` | Swift Testing — `@Test`, `#expect`, traits, parameterized tests. |
| `swift-architecture-pro` | Feature modularization, MVVM, dependency injection, routing. |
| `swift-performance-pro` | Instruments, render cost, memory/retain cycles, launch time. |

### Platform & integration

| Skill | What it does |
|-------|--------------|
| `swift-accessibility-pro` | VoiceOver, Dynamic Type, contrast, Reduce Motion, a11y testing. |
| `app-intents-pro` | App Intents — Siri, Shortcuts, Spotlight, `AppEntity`, App Shortcuts. |
| `swift-security-pro` | Keychain, Data Protection, ATS/TLS, secrets, biometrics. |

## 📦 Install

<details open>
<summary><b>Claude Code (recommended)</b></summary>

```bash
/plugin marketplace add laxrajpurohit/swift-skills-pro
/plugin install swiftui-pro@swift-skills-pro
```

Swap `swiftui-pro` for any skill name (e.g. `swift-concurrency-pro@swift-skills-pro`).

</details>

<details>
<summary><b>npx (cross-tool)</b></summary>

```bash
npx skills add https://github.com/laxrajpurohit/swift-skills-pro --skill swiftui-pro
```

Requires Node.js (`brew install node`).

</details>

<details>
<summary><b>Manual</b></summary>

```bash
git clone https://github.com/laxrajpurohit/swift-skills-pro
cp -R swift-skills-pro/swiftui-pro/skills/swiftui-pro ~/.claude/skills/swiftui-pro
```

</details>

## ⚡ Usage

Trigger an installed skill with its slash command — or just ask in natural language
("review this SwiftUI view", "make this screen accessible").

| Skill | Trigger | | Skill | Trigger |
|-------|---------|---|-------|---------|
| swiftui-pro | `/swiftui-pro` | | swift-architecture-pro | `/swift-architecture-pro` |
| swift-concurrency-pro | `/swift-concurrency-pro` | | swift-performance-pro | `/swift-performance-pro` |
| swiftdata-pro | `/swiftdata-pro` | | swift-accessibility-pro | `/swift-accessibility-pro` |
| swift-testing-pro | `/swift-testing-pro` | | app-intents-pro | `/app-intents-pro` |
| swift-language-pro | `/swift-language-pro` | | swift-security-pro | `/swift-security-pro` |
| core-data-pro | `/core-data-pro` | | | |

## 🧪 Compatibility

| Tool | Status | Notes |
|------|--------|-------|
| Claude Code | ✅ Tested | Full plugin marketplace support |
| Cursor | ✅ Compatible | Via skills directory |
| Windsurf | ✅ Compatible | Via skills directory |
| Codex | ✅ Compatible | Via skills directory |
| Other agent tools | 🔄 Should work | Any tool supporting Agent-Skills format |

## 🔒 Safety

These skills instruct AI tools how to write your code. Read a skill before installing and
make sure you trust it — **you are responsible for the code your tools produce.**

## ℹ️ About

All skills here are **original**, written from scratch for the modern Swift toolchain
(Swift 6 / iOS 26). Nothing is copied from any other project or author.

## 🤝 Contributing

Contributions welcome. Please ensure:

- Content is written by a human, not generated wholesale by AI.
- No plagiarism — write your own material.
- An App-Store-compatible license (MIT, Apache 2, BSD, ISC).
- You follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## 📄 License

[MIT](LICENSE) © 2026 Lax Rajpurohit.
