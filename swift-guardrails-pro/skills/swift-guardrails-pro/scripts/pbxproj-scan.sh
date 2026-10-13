#!/bin/bash
# Scans Xcode project files for build-phase injection, the trick Xcode-project
# infectors use to run a hidden payload on every build of every machine that
# clones the repo.
#
#   pbxproj-scan.sh           # staged project.pbxproj files (pre-commit)
#   pbxproj-scan.sh --all     # every project.pbxproj in the working tree
#
# A hit blocks the commit. Never "fix" a hit by editing the pattern list:
# find out what wrote it.

set -uo pipefail
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not inside a git repository."; exit 3; }
cd "$ROOT" || exit 3

ALL=0
[ "${1:-}" = "--all" ] && ALL=1

# label|extended regex. Each is something a normal Xcode project never contains.
PATTERNS='base64 decode|base64[[:space:]]+(--decode|-d|-D)
hex decode chain|xxd[[:space:]]+-p[[:space:]]+-r
remote script piped to a shell|(curl|wget).*\|[[:space:]]*(ba|z)?sh
shell running an expanded variable|sh[[:space:]]+-c[[:space:]]+"?\$\{
hidden background process|>[[:space:]]*/dev/null[[:space:]]+2>&1[[:space:]]*&
eval of a variable|eval[[:space:]]+"?\$
osascript call|osascript[[:space:]]
download into a temp folder|(curl|wget).*(/tmp/|\$TMPDIR)'

if [ $ALL -eq 1 ]; then
  LIST=$(git ls-files '*.pbxproj')
else
  LIST=$(git diff --cached --name-only --diff-filter=ACMR -- '*.pbxproj')
fi
[ -n "$LIST" ] || exit 0

FOUND=0
while IFS= read -r proj; do
  [ -n "$proj" ] || continue
  if [ $ALL -eq 1 ]; then
    CONTENT=$(cat "$proj" 2>/dev/null)
  else
    CONTENT=$(git show ":$proj" 2>/dev/null)
  fi
  [ -n "$CONTENT" ] || continue

  while IFS='|' read -r label regex; do
    [ -n "$regex" ] || continue
    if printf '%s' "$CONTENT" | grep -qiE "$regex"; then
      echo "BLOCKED: $label in $proj"
      printf '%s' "$CONTENT" | grep -niE "$regex" | head -3 | cut -c1-160 | sed 's/^/    /'
      FOUND=1
    fi
  done <<EOF
$PATTERNS
EOF
done <<EOF
$LIST
EOF

if [ $FOUND -ne 0 ]; then
  cat <<'MSG'

Suspicious build-phase content in an Xcode project file.
This is how Xcode-project malware spreads: it rewrites project.pbxproj on an
infected Mac and rides along in the next commit. Do not commit. Inspect the
"Run Script" phases in Xcode, and treat the machine as infected until the
source of the edit is found.
MSG
  exit 1
fi
[ $ALL -eq 1 ] && echo "No suspicious build-phase content found."
exit 0
