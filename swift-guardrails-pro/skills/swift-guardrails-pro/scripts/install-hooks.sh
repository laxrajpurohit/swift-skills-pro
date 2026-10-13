#!/bin/bash
# Optional: also run the checks on commits made outside Claude Code (terminal,
# Xcode, a Git GUI). Claude's own commits need nothing; the plugin covers them.
#
#   install-hooks.sh            # this clone only; points at the installed skill
#   install-hooks.sh --vendor   # copy the scripts into scripts/guardrails/ so
#                               # every teammate gets them from the repo
#
# Leaves an existing, unrelated pre-commit hook alone and explains how to chain it.

set -uo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not inside a git repository."; exit 3; }
cd "$ROOT" || exit 3

TARGET="$SRC/pre-commit"
if [ "${1:-}" = "--vendor" ]; then
  mkdir -p scripts/guardrails
  cp "$SRC"/_common.sh "$SRC"/_filter.py "$SRC"/lint-changed.sh "$SRC"/dup-check.sh \
     "$SRC"/pbxproj-scan.sh "$SRC"/pre-commit scripts/guardrails/
  # lint-changed.sh falls back to <skill>/templates/swiftlint.yml; vendored copies
  # use the repo's own config instead.
  [ -f .swiftlint.yml ] || [ -f .swiftlint.yaml ] || cp "$SRC/../templates/swiftlint.yml" .swiftlint.yml
  chmod +x scripts/guardrails/*.sh scripts/guardrails/pre-commit
  TARGET='$(git rev-parse --show-toplevel)/scripts/guardrails/pre-commit'
  echo "Copied the checks into scripts/guardrails/ (commit them)."
fi

HOOKS_DIR=$(git rev-parse --git-path hooks)
HOOK="$HOOKS_DIR/pre-commit"
MARKER="# swift-guardrails"
mkdir -p "$HOOKS_DIR"

if [ -f "$HOOK" ] && ! grep -q "$MARKER" "$HOOK"; then
  echo "A pre-commit hook already exists at $HOOK and was left untouched."
  echo "To chain swift-guardrails, add this line to it:"
  echo "  bash \"$TARGET\" || exit 1"
  exit 1
fi

cat > "$HOOK" <<EOF
#!/bin/bash
$MARKER
exec bash "$TARGET" "\$@"
EOF
chmod +x "$HOOK"
echo "Installed $HOOK"
