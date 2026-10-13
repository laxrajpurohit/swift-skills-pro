"""Maps tool reports onto the lines a diff touched, so legacy code stays quiet.

    python3 _filter.py lint <swiftlint.json> <hunks.diff> [--all-lines] [--warnings]
    python3 _filter.py dup  <jscpd.json>     <hunks.diff> <mode> <source> <shared-home>

Exit codes: 0 clean, 1 findings.
"""

import json
import os
import re
import sys


def touched_lines(hunks_path):
    """Repo-relative path -> set of line numbers added or modified in the diff."""
    touched, current = {}, None
    with open(hunks_path) as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith("+++ "):
                path = line[4:].strip()
                current = None if path == "/dev/null" else (path[2:] if path.startswith("b/") else path)
                if current:
                    touched.setdefault(current, set())
            elif line.startswith("@@") and current:
                m = re.search(r"\+(\d+)(?:,(\d+))?", line)
                if m:
                    start = int(m.group(1))
                    count = int(m.group(2)) if m.group(2) is not None else 1
                    touched[current].update(range(start, start + count))
    return touched


def repo_relative(path):
    # realpath on both sides: on macOS /var is a symlink to /private/var.
    root = os.path.realpath(os.getcwd())
    if os.path.isabs(path):
        return os.path.relpath(os.path.realpath(path), root)
    return os.path.normpath(path)


def lint(report_path, hunks_path, all_lines, fail_on_warning):
    raw = open(report_path).read()
    try:
        violations = json.loads(raw) if raw.strip() else []
    except json.JSONDecodeError:
        print("Could not parse SwiftLint output:\n" + raw[:2000])
        return 1

    touched = touched_lines(hunks_path)
    kept = []
    for v in violations:
        rel = repo_relative(v.get("file", ""))
        if all_lines or v.get("line") in touched.get(rel, set()):
            kept.append((rel, v))

    if not kept:
        if violations:
            print(f"No violations on changed lines. ({len(violations)} pre-existing in these files; "
                  f"run with --all-lines to see them.)")
        else:
            print("No violations.")
        return 0

    errors = 0
    kept.sort(key=lambda k: (k[0], k[1].get("line") or 0))
    for rel, v in kept:
        sev = (v.get("severity") or "warning").lower()
        errors += sev == "error"
        print(f"{rel}:{v.get('line')}:{v.get('character') or 1}: {sev}: {v.get('reason')} ({v.get('rule_id')})")

    scope = "in touched files" if all_lines else "on changed lines"
    print(f"\n{len(kept)} violation(s) {scope}, {errors} error(s).")
    # Warnings fail only where asked (the editor hook, so the agent sees them);
    # a commit is blocked by errors alone.
    return 1 if errors or fail_on_warning else 0


# A clone counts only when at least half of one copy is new: that catches a
# pasted block, not a one-token fix inside an old duplicate.
NEW_SHARE = 0.5


def dup(report_path, hunks_path, mode, source, shared_home):
    touched = touched_lines(hunks_path)
    clones = json.load(open(report_path)).get("duplicates", [])

    def hit(frag):
        lines = touched.get(repo_relative(frag["name"]))
        if not lines:
            return False
        span = range(frag["start"], frag["end"] + 1)
        return sum(1 for n in span if n in lines) >= NEW_SHARE * len(span)

    found = [c for c in clones if hit(c["firstFile"]) or hit(c["secondFile"])]
    if not found:
        if mode != "file":
            print("No new copy-paste on changed lines.")
        return 0

    out = sys.stdout
    print(f"Copy-paste detected in {source}: {len(found)} duplicated block(s)", file=out)
    for c in found:
        a, b = c["firstFile"], c["secondFile"]
        print(f"  {repo_relative(a['name'])}:{a['start']}-{a['end']}  ==  "
              f"{repo_relative(b['name'])}:{b['start']}-{b['end']}  ({c['lines']} lines)", file=out)
    print(f"\nMove the shared block into {shared_home} and call it from both places.", file=out)
    if mode == "staged":
        print("Deliberate? Commit with SKIP_DUP_CHECK=1 git commit ...", file=out)
    return 1


if __name__ == "__main__":
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "lint":
        sys.exit(lint(args[0], args[1], "--all-lines" in args[2:], "--warnings" in args[2:]))
    if cmd == "dup":
        sys.exit(dup(*args[:5]))
    sys.exit(f"unknown command: {cmd}")
