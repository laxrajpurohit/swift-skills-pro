#!/bin/bash
# Editor-agent hook entry point. One script for every agent; the installer
# (or the Claude Code plugin) registers it in each agent's hook config.
#
#   agent-hook.sh <agent> post-edit    after the agent edits files: lint and
#                                      copy-paste check the edited Swift files
#   agent-hook.sh <agent> pre-commit   before the agent runs a shell command:
#                                      when it is a `git commit`, run the full suite
#
#   <agent>: claude | cursor | codex | windsurf
#
# Reads the hook JSON on stdin and answers in that agent's format. Anything
# that isn't a finding (not a git repo, no Swift code, a missing tool) lets the
# action through silently, so the hook never gets in the way.

DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="${1:-claude}"
EVENT="${2:-}"
INPUT=$(cat)

command -v python3 >/dev/null 2>&1 || exit 0

# Pulls the edited files, the command, and its directory out of whichever
# shape this agent sends. Prints three sections separated by NUL-free markers.
PARSED=$(printf '%s' "$INPUT" | python3 -I -c '
import json, os, re, sys

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

def get(*keys):
    for key in keys:
        v = d
        for part in key.split("."):
            v = v.get(part) if isinstance(v, dict) else None
        if isinstance(v, str) and v:
            return v
    return ""

cwd = get("cwd", "tool_info.cwd") or (d.get("workspace_roots") or [""])[0]
command = get("tool_input.command", "command", "tool_info.command_line")

files = []
direct = get("tool_input.file_path", "tool_input.path", "tool_input.target_file",
             "tool_response.filePath", "file_path", "tool_info.file_path")
if direct:
    files.append(direct)
elif d.get("tool_name") == "apply_patch" or "*** Begin Patch" in command:
    # Codex: paths live inside the patch text, relative to cwd.
    files += re.findall(r"^\*\*\* (?:Update|Add) File: (.+)$", command, re.M)
    moved = re.findall(r"^\*\*\* Move to: (.+)$", command, re.M)
    files += moved
    command = ""

files = [f if os.path.isabs(f) else os.path.join(cwd or ".", f) for f in files]
print("CWD\t" + cwd)
print("CMD\t" + command.replace("\n", " "))
for f in files:
    print("FILE\t" + f)
' 2>/dev/null)

CWD=$(printf '%s\n' "$PARSED" | sed -n 's/^CWD	//p')
CMD=$(printf '%s\n' "$PARSED" | sed -n 's/^CMD	//p')
FILES=$(printf '%s\n' "$PARSED" | sed -n 's/^FILE	//p')

# Runs a check; on findings (exit 1) collects its output.
REPORT=""
check() {
  local out status
  out=$(bash "$@" 2>&1)
  status=$?
  [ $status -eq 1 ] && REPORT="$REPORT$out"$'\n\n'
  return 0
}

case "$EVENT" in
  post-edit)
    while IFS= read -r f; do
      case "$f" in *.swift) ;; *) continue ;; esac
      [ -f "$f" ] || continue
      cd "$(dirname "$f")" 2>/dev/null || continue
      command -v swiftlint >/dev/null 2>&1 && check "$DIR/lint-changed.sh" --file "$f"
      command -v jscpd >/dev/null 2>&1 && check "$DIR/dup-check.sh" --file "$f"
    done <<EOF
$FILES
EOF
    ;;
  pre-commit)
    printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit\b' || exit 0
    [ -n "$CWD" ] && cd "$CWD" 2>/dev/null
    git rev-parse --show-toplevel >/dev/null 2>&1 || exit 0
    check "$DIR/pbxproj-scan.sh"
    command -v swiftlint >/dev/null 2>&1 && check "$DIR/lint-changed.sh" --staged
    if command -v jscpd >/dev/null 2>&1 && ! printf '%s' "$CMD" | grep -q 'SKIP_DUP_CHECK=1'; then
      check "$DIR/dup-check.sh" --staged
    fi
    ;;
  *)
    exit 0
    ;;
esac

[ -z "$REPORT" ] && exit 0
MSG=$(printf 'swift-guardrails:\n\n%s' "$REPORT")

# Cursor takes JSON on stdout: additional_context after a tool, a deny before a command.
if [ "$AGENT" = "cursor" ]; then
  MSG="$MSG" EVENT="$EVENT" python3 -I -c '
import json, os
msg = os.environ["MSG"]
if os.environ["EVENT"] == "pre-commit":
    print(json.dumps({"permission": "deny", "user_message": "swift-guardrails blocked the commit.", "agent_message": msg}))
else:
    print(json.dumps({"additional_context": msg}))
'
  exit 0
fi

# Claude Code, Codex, Windsurf: exit 2 with the reason on stderr.
printf '%s\n' "$MSG" >&2
exit 2
