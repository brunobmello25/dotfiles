#!/bin/env bash

set -euo pipefail

# Check if we are inside any git repo (bare or not)
if ! git rev-parse --git-dir &>/dev/null; then
  echo "Not inside a git repository." >&2
  exit 1
fi

# Check if it's a bare repo
if [ "$(git rev-parse --is-bare-repository)" != "true" ]; then
  echo "Not a bare repository." >&2
  exit 1
fi

SESSION_PREFIX="${1:-wt}"

sanitize_name() {
  echo "$1" | sed 's/[\/:+]/-/g'
}

git worktree list --porcelain | awk '
  /^worktree / { wt = substr($0, 10) }
  /^branch / { branch = substr($0, 8) }
  /^$/{ if (wt != "" && branch != "") print wt, branch; wt=""; branch="" }
  END{ if (wt != "" && branch != "") print wt, branch }
' | while read -r worktree_path branch; do
  if [ -z "$branch" ] || [ "$branch" = "(detached HEAD)" ]; then
    echo "Skipping detached HEAD at $worktree_path" >&2
    continue
  fi

  # Strip refs/heads/ prefix
  branch_name="${branch#refs/heads/}"
  safe_name=$(sanitize_name "$branch_name")
  session_name="${SESSION_PREFIX}-${safe_name}"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Session '$session_name' already exists, skipping." >&2
    continue
  fi

  tmux new-session -d -s "$session_name" -c "$worktree_path" -n "$branch_name"
  echo "Created session '$session_name' for branch '$branch_name' at $worktree_path"
done
