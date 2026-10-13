#!/bin/bash
# Copy-paste detector for the lines you changed, using the same ratchet as lint-changed.sh.
#
# Flags a clone only when at least half of one of its copies is new, so legacy
# duplicates stay quiet. Fix one by moving the block into a shared component
# and calling it from both places.
#
#   dup-check.sh                 # vs the base branch (auto-detected)
#   dup-check.sh develop         # vs another base
#   dup-check.sh --staged        # staged changes only (pre-commit)
#   dup-check.sh --file <path>   # one file's uncommitted changes (editor hook)

set -uo pipefail
. "$(dirname "$0")/_common.sh"

MODE="base"
ONE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --staged) MODE="staged" ;;
    --file)   MODE="file"; shift; ONE_FILE="${1:-}" ;;
    -*)       echo "Unknown option: $1"; exit 3 ;;
    *)        BASE_REF="$1" ;;
  esac
  shift
done

for tool in jscpd python3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "$tool not found. Install it with:  brew install $tool"; exit 127; }
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
HUNKS="$TMP/hunks.diff"

case "$MODE" in
  staged)
    git diff -U0 --cached -- "${PATHSPECS[@]}" > "$HUNKS"
    SOURCE="staged changes"
    ;;
  file)
    ONE_FILE=$(repo_path "$ONE_FILE")
    in_scope "$ONE_FILE" && [ -f "$ONE_FILE" ] || exit 0
    file_hunks "$ONE_FILE" "$HUNKS"
    SOURCE="$ONE_FILE"
    ;;
  *)
    BASE=$(base_commit) || exit 3
    git diff -U0 "$BASE" -- "${PATHSPECS[@]}" > "$HUNKS"
    SOURCE="changes vs $BASE_REF"
    ;;
esac

if [ ! -s "$HUNKS" ]; then
  [ "$MODE" = "file" ] || echo "No Swift changes in $SOURCE, nothing to check."
  exit 0
fi

IGNORE="**/Pods/**,**/.build/**,**/*.xcassets/**"
for d in $EXCLUDE_DIRS; do IGNORE="$IGNORE,$d/**"; done

# Scan from the repo root with a pattern: given folders directly, jscpd names
# files relative to each folder, which can't be matched back to the diff.
set -- $SOURCE_DIRS
if [ $# -eq 1 ]; then PATTERN="$1/**/*.swift"; else PATTERN="{$(echo "$*" | tr ' ' ',')}/**/*.swift"; fi

jscpd . --pattern "$PATTERN" --format swift --ignore "$IGNORE" \
  --min-lines "$DUP_MIN_LINES" --min-tokens "$DUP_MIN_TOKENS" \
  --reporters json --output "$TMP" --silent >/dev/null 2>&1

if [ ! -f "$TMP/jscpd-report.json" ]; then
  [ "$MODE" = "file" ] || echo "jscpd produced no report."
  exit 0
fi

python3 -I "$SCRIPT_DIR/_filter.py" dup "$TMP/jscpd-report.json" "$HUNKS" "$MODE" "$SOURCE" "$SHARED_HOME"
