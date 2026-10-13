#!/bin/bash
# Shared setup for the swift-guardrails scripts. Sourced, never run directly.
#
# Works with zero configuration: run from anywhere inside a git repo and it
# finds the Swift source folders, the base branch, and a SwiftLint config.
# An optional .swift-guardrails file at the repo root (plain KEY="value"
# lines) overrides any of:
#   SOURCE_DIRS     space-separated folders holding the app's Swift code
#   EXCLUDE_DIRS    space-separated folders to skip (vendored / generated code)
#   BASE_REF        branch the ratchet compares against
#   DUP_MIN_LINES / DUP_MIN_TOKENS   jscpd thresholds
#   SHARED_HOME     where a duplicated block should move (shown in the fix hint)
#
# Exit codes used by every script: 0 clean, 1 findings, 3 setup problem,
# 127 missing tool.
#
# Written for bash 3.2, the version macOS ships: no mapfile, no associative arrays.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CALLER_DIR="$(pwd)"

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "swift-guardrails: not inside a git repository."
  exit 3
}
cd "$ROOT" || exit 3

SOURCE_DIRS=""
EXCLUDE_DIRS=""
BASE_REF=""
DUP_MIN_LINES=8
DUP_MIN_TOKENS=60
SHARED_HOME=""

# shellcheck disable=SC1091
[ -f .swift-guardrails ] && . ./.swift-guardrails

# Every top-level folder holding tracked Swift files, minus dependency folders.
if [ -z "$SOURCE_DIRS" ]; then
  SOURCE_DIRS=$(git ls-files '*.swift' | grep / | cut -d/ -f1 | sort -u \
    | grep -v -E '^(Pods|Carthage|\.build|DerivedData|[Vv]endor|Packages)$' | tr '\n' ' ')
fi
if [ -z "${SOURCE_DIRS// /}" ]; then
  echo "swift-guardrails: no Swift source folders found. Set SOURCE_DIRS in .swift-guardrails."
  exit 3
fi

# The remote's default branch, else the first common name that exists.
if [ -z "$BASE_REF" ]; then
  BASE_REF=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
  for ref in origin/main origin/master main master; do
    [ -n "$BASE_REF" ] && break
    git rev-parse --verify --quiet "$ref" >/dev/null && BASE_REF="$ref"
  done
fi

if [ -z "$SHARED_HOME" ]; then
  for d in $SOURCE_DIRS; do
    SHARED_HOME=$(find "$d" -type d \( -name Components -o -name Shared -o -name Common -o -name DesignSystem \) \
      -not -path '*/.*' 2>/dev/null | head -1)
    [ -n "$SHARED_HOME" ] && break
  done
  [ -n "$SHARED_HOME" ] || SHARED_HOME="a shared component or helper"
fi

# The repo's own SwiftLint config wins; otherwise the one bundled with the skill.
SWIFTLINT_ARGS=()
if [ ! -f .swiftlint.yml ] && [ ! -f .swiftlint.yaml ]; then
  SWIFTLINT_ARGS=(--config "$SKILL_DIR/templates/swiftlint.yml")
fi

PATHSPECS=()
for d in $SOURCE_DIRS; do PATHSPECS+=("$d/*.swift"); done
for d in $EXCLUDE_DIRS; do PATHSPECS+=(":(exclude)$d"); done

# True when $1 (repo-relative) is a Swift file inside SOURCE_DIRS and outside EXCLUDE_DIRS.
in_scope() {
  local f="$1" d ok=1
  case "$f" in *.swift) ;; *) return 1 ;; esac
  for d in $SOURCE_DIRS; do
    case "$f" in "$d"/*) ok=0 ;; esac
  done
  [ $ok -eq 0 ] || return 1
  for d in $EXCLUDE_DIRS; do
    case "$f" in "$d"/*) return 1 ;; esac
  done
  return 0
}

# Prints the merge-base with BASE_REF, or explains why there is none.
base_commit() {
  if [ -z "$BASE_REF" ] || ! git rev-parse --verify --quiet "$BASE_REF" >/dev/null; then
    echo "Base ref '${BASE_REF:-<none>}' not found. Pass one (e.g. main) or set BASE_REF in .swift-guardrails." >&2
    return 3
  fi
  git merge-base HEAD "$BASE_REF"
}

# Repo-relative form of a path given absolute or relative to the caller's directory.
repo_path() {
  local p="$1"
  case "$p" in /*) ;; *) p="$CALLER_DIR/$p" ;; esac
  p="$(cd "$(dirname "$p")" 2>/dev/null && pwd -P)/$(basename "$p")"
  echo "${p#"$(pwd -P)/"}"
}

# Writes the uncommitted hunks of one file to $2. Untracked: every line is new.
file_hunks() {
  if git ls-files --error-unmatch "$1" >/dev/null 2>&1; then
    git diff -U0 HEAD -- "$1" > "$2"
  else
    git diff -U0 --no-index /dev/null "$1" > "$2"
  fi
}
