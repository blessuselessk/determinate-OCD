#!/usr/bin/env bash
# Git wrapper that refuses to run in jj-managed repos.
# Placed higher on PATH than real git to enforce jj usage.

# Find the real git by searching PATH, skipping ourselves
SELF="$(realpath "$0")"
REAL_GIT=""
IFS=: read -ra path_dirs <<< "$PATH"
for d in "${path_dirs[@]}"; do
  candidate="$d/git"
  if [ -x "$candidate" ] && [ "$(realpath "$candidate")" != "$SELF" ]; then
    REAL_GIT="$candidate"
    break
  fi
done

if [ -z "$REAL_GIT" ]; then
  echo "error: git-jj-guard: could not find real git on PATH" >&2
  exit 1
fi

# Walk up to find .jj
dir="$PWD"
while [ "$dir" != "/" ]; do
  if [ -d "$dir/.jj" ]; then
    echo "error: this is a jj-managed repo ($dir)" >&2
    echo "  use 'jj' instead of 'git'" >&2
    echo "  or run the real git directly: $REAL_GIT" >&2
    exit 1
  fi
  dir=$(dirname "$dir")
done

# Not a jj repo — pass through to real git
exec "$REAL_GIT" "$@"
