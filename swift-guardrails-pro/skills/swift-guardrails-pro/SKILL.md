---
name: swift-guardrails-pro
description: Use when checking Swift / iOS code for lint violations, copy-pasted (duplicate) code, or Xcode project malware — runs ratcheted SwiftLint, a jscpd copy-paste detector, and a project.pbxproj build-phase scan on changed lines only. Also use to add a project lint rule or enable the checks for teammates' commits.
license: MIT
metadata:
  author: Lax Rajpurohit
  version: "1.0.0"
---

# Swift Guardrails Pro

Coding rules that run on their own instead of advice someone has to remember.
Everything is a **ratchet**: only lines a change adds or modifies are checked, so
a legacy codebase adopts it on day one with no cleanup sprint.

**No setup.** Nothing is copied into the project. The scripts sit next to this
file in `scripts/` and work out the source folders, base branch, and lint config
on their own. Installing the skill also wires them into the agent's hooks, so
they run automatically:

| When | What runs | Effect |
|------|-----------|--------|
| After the agent edits a `.swift` file | lint + copy-paste on that file's changed lines | findings go back to the agent to fix |
| Before the agent runs `git commit` | pbxproj scan + lint + copy-paste on staged lines | commit blocked until fixed |

| Installed via | Hooks registered in |
|---------------|---------------------|
| Claude Code plugin | the plugin itself |
| `npx swift-skills-cli install` | `~/.claude/settings.json`, `~/.cursor/hooks.json`, `~/.codex/hooks.json`, `~/.codeium/windsurf/hooks.json` (each agent found on the machine) |
| Manual copy | none yet; see "Registering hooks by hand" |

## When to use

- "Check my changes", "lint this branch", "any copy-paste in this PR?"
- "Stop copy-pasted views", "make sure nobody duplicates code".
- Adding a project-specific rule (design tokens, banned APIs).
- Enabling the checks for commits made outside Claude Code.

Trigger: `/swift-guardrails-pro` or natural language.

## The checks

`<skill>` below is this file's directory. Run from anywhere inside the repo.

| Script | Tool | Fails on |
|--------|------|----------|
| `<skill>/scripts/lint-changed.sh` | SwiftLint | `error` violations on changed lines (after an edit, `warning`s too, so the agent fixes them; a commit is blocked by errors only) |
| `<skill>/scripts/dup-check.sh` | jscpd | a duplicated block (≥ 8 lines / 60 tokens) that is at least half new |
| `<skill>/scripts/pbxproj-scan.sh` | grep | build-phase injection in `project.pbxproj` (base64/xxd decode, `curl \| sh`, hidden background jobs, `osascript`) |

```bash
lint-changed.sh                 # lines changed vs the base branch
lint-changed.sh --all-lines     # every violation in the touched files
lint-changed.sh --staged        # staged lines only
lint-changed.sh --file <path>   # one file's uncommitted lines
dup-check.sh                    # same modes: <base>, --staged, --file <path>
pbxproj-scan.sh --all           # every Xcode project file in the repo
```

Exit codes: `0` clean, `1` findings, `3` not a git repo / no Swift code, `127` tool missing.
On `127`, tell the user the one-line fix (`brew install swiftlint jscpd`). Don't install without asking.

## Defaults it works out

| Setting | Default |
|---------|---------|
| Source folders | every top-level folder with tracked `.swift` files, minus `Pods`, `Carthage`, `.build`, `DerivedData`, `Vendor`, `Packages` |
| Base branch | `origin/HEAD`, else `origin/main`, `origin/master`, `main`, `master` |
| SwiftLint config | the repo's `.swiftlint.yml`; none → `<skill>/templates/swiftlint.yml` |
| Shared home (fix hint) | first `Components`, `Shared`, `Common`, or `DesignSystem` folder found |

Only when a default is wrong, create `.swift-guardrails` at the repo root:

```bash
SOURCE_DIRS="MyApp MyAppKit"   # space-separated
EXCLUDE_DIRS="MyApp/Generated"
BASE_REF="origin/develop"
DUP_MIN_LINES=8
DUP_MIN_TOKENS=60
SHARED_HOME="MyApp/UI/Components"
```

## Fixing what they report

- **Copy-paste** → extract the block into the shared home (a view, a `ViewModifier`,
  or a function) and call it from both places. Don't rename variables or reshuffle
  lines to dodge the detector. The goal is one copy.
- **Lint** → fix the line. If the rule is wrong for that spot:
  `// swiftlint:disable:next <rule_id> — <reason>`.
- **pbxproj** → stop. Never edit the pattern list or bypass the check. Open the
  target's Build Phases in Xcode, find the script, and treat the Mac as possibly
  infected until the source of the edit is known.
- **Deliberate duplicate** → prefix the commit with `SKIP_DUP_CHECK=1`.

## Adding a project rule

1. Copy `<skill>/templates/swiftlint.yml` to the repo as `.swiftlint.yml`, if the repo has none.
   If it has one, append the rule under `custom_rules`, and when it uses `only_rules`,
   make sure `custom_rules` is listed there.
2. Highest-value pattern: forbid a raw value everywhere except the file that defines the token.

```yaml
hardcoded_color:
  name: "Hardcoded color"
  regex: '\bColor\((red|hex):|#colorLiteral\('
  message: "Use a color token from Theme/Tokens.swift. If none fits, add one there."
  severity: error
  excluded_match_kinds: [comment, doccomment]
  excluded: ".*/Theme/Tokens\\.swift"
```

- The `message` names the replacement, not just the problem.
- `excluded` lists the one file allowed to hold the raw value.
- Test with `swiftlint lint --quiet <file>` on one file that should match and one that shouldn't.
- Start at `warning`; promote to `error` once the team agrees.

## Commits outside Claude Code (optional)

Only on request:

```bash
<skill>/scripts/install-hooks.sh            # git pre-commit for this clone
<skill>/scripts/install-hooks.sh --vendor   # copy the checks into scripts/guardrails/
                                            # so every teammate's commit runs them
```

Neither replaces an existing pre-commit hook. They print the line to chain instead.

## Registering hooks by hand

Only on request, when the skill was copied manually. `<script>` is the absolute
path of `<skill>/scripts/agent-hook.sh`. Merge into the file; keep every existing key and hook.

| Agent | File | Add |
|-------|------|-----|
| Claude Code | `~/.claude/settings.json` | `hooks.PostToolUse`: `{"matcher": "Edit\|Write\|MultiEdit", "hooks": [{"type": "command", "command": "bash \"<script>\" claude post-edit"}]}`; `hooks.PreToolUse`: same with `"matcher": "Bash"` and `claude pre-commit` |
| Cursor | `~/.cursor/hooks.json` | `"version": 1`; `hooks.postToolUse`: `{"command": "bash \"<script>\" cursor post-edit", "matcher": "Write"}`; `hooks.beforeShellExecution`: `{"command": "bash \"<script>\" cursor pre-commit"}` |
| Codex | `~/.codex/hooks.json` | as Claude Code, with `"matcher": "apply_patch\|Edit\|Write"` and `codex …`. Then trust them with `/hooks` |
| Windsurf | `~/.codeium/windsurf/hooks.json` | `hooks.post_write_code`: `{"command": "bash \"<script>\" windsurf post-edit", "show_output": true}`; `hooks.pre_run_command`: same with `windsurf pre-commit` |

## Common mistakes

- Running `swiftlint` on the whole repo and drowning in legacy warnings. Use the scripts.
- Overwriting an existing `.swiftlint.yml`. Always merge.
- Silencing a copy-paste hit by renaming variables instead of extracting the block.
- Listing `Pods` or generated code in `SOURCE_DIRS`, which floods the copy-paste check.

## Output format

Report each finding as `path:line → problem → fix`, then one summary line with
the counts. Clean run → one line saying so.
