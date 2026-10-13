#!/bin/bash
# SwiftLint on the lines you changed: a ratchet, not a repo-wide gate.
#
# Linting whole files turns a one-line edit in a big legacy screen red, so only
# violations on added or modified lines are reported. Old debt stays quiet
# until someone touches it.
#
#   lint-changed.sh                 # vs the base branch (auto-detected)
#   lint-changed.sh develop         # vs another base
#   lint-changed.sh --staged        # staged changes only (pre-commit)
#   lint-changed.sh --file <path>   # one file's uncommitted changes (editor hook;
#                                   # warnings fail too, so the agent sees them)
#   lint-changed.sh --all-lines     # every violation in the touched files

set -uo pipefail
. "$(dirname "$0")/_common.sh"

ALL_LINES=""
MODE="base"
ONE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --all-lines) ALL_LINES="--all-lines" ;;
    --staged)    MODE="staged" ;;
    --file)      MODE="file"; shift; ONE_FILE="${1:-}" ;;
    -*)          echo "Unknown option: $1"; exit 3 ;;
    *)           BASE_REF="$1" ;;
  esac
  shift
done

for tool in swiftlint python3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "$tool not found. Install it with:  brew install $tool"; exit 127; }
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
HUNKS="$TMP/hunks.diff"

case "$MODE" in
  staged)
    git diff -U0 --cached -- "${PATHSPECS[@]}" > "$HUNKS"
    LIST=$(git diff --name-only --diff-filter=ACMR --cached -- "${PATHSPECS[@]}")
    SOURCE="staged changes"
    ;;
  file)
    ONE_FILE=$(repo_path "$ONE_FILE")
    in_scope "$ONE_FILE" && [ -f "$ONE_FILE" ] || exit 0
    file_hunks "$ONE_FILE" "$HUNKS"
    LIST="$ONE_FILE"
    SOURCE="$ONE_FILE"
    ;;
  *)
    BASE=$(base_commit) || exit 3
    git diff -U0 "$BASE" -- "${PATHSPECS[@]}" > "$HUNKS"
    LIST=$(git diff --name-only --diff-filter=ACMR "$BASE" -- "${PATHSPECS[@]}")
    SOURCE="changes vs $BASE_REF"
    ;;
esac

FILES=()
while IFS= read -r f; do
  [ -n "$f" ] && [ -f "$f" ] && FILES+=("$f")
done <<EOF
$LIST
EOF

if [ ${#FILES[@]} -eq 0 ] || [ ! -s "$HUNKS" ]; then
  [ "$MODE" = "file" ] || echo "No Swift changes in $SOURCE, nothing to lint."
  exit 0
fi

[ "$MODE" = "file" ] || echo "Linting ${#FILES[@]} changed file(s) from $SOURCE..."

# Report goes through a file: a large diff exceeds the per-argument limit.
swiftlint lint --quiet --reporter json --force-exclude ${SWIFTLINT_ARGS[@]+"${SWIFTLINT_ARGS[@]}"} \
  -- "${FILES[@]}" > "$TMP/report.json" 2>/dev/null

# In the editor hook warnings count too, so the agent fixes them while the code is fresh.
WARNINGS=""
[ "$MODE" = "file" ] && WARNINGS="--warnings"

OUT=$(python3 -I "$SCRIPT_DIR/_filter.py" lint "$TMP/report.json" "$HUNKS" $ALL_LINES $WARNINGS)
STATUS=$?
# The editor hook only wants to hear about problems.
[ "$MODE" = "file" ] && [ $STATUS -eq 0 ] && exit 0
echo "$OUT"
exit $STATUS
