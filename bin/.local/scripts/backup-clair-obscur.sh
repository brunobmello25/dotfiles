#!/usr/bin/env bash
set -euo pipefail

#
# CONFIGURE THESE:
#
SRC="$HOME/.local/share/Steam/steamapps/compatdata/1903340/pfx/drive_c/users/steamuser/AppData/Local/Sandfall/Saved/SaveGames/76561198068483201"
DEST="$HOME/Documents/backup-clair-obscur"
#

# sanity checks
if [ ! -d "$SRC" ]; then
  echo "Error: source folder '$SRC' does not exist." >&2
  exit 1
fi

if [ ! -d "$DEST" ]; then
  echo "Error: destination folder '$DEST' does not exist." >&2
  exit 1
fi

if [ ! -d "$DEST/.git" ]; then
  echo "Error: '$DEST' is not a git repository." >&2
  exit 1
fi

# sync files
rsync -av --delete --exclude='.git/' "$SRC"/ "$DEST"/

# commit & push
cd "$DEST"

git add --all

# see if there's *any* change (unstaged, staged, untracked, deleted...)
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  exit 0
fi

TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
COMMIT_MSG="Sync from $(basename "$SRC") on $TIMESTAMP"

git add .
git commit -m "$COMMIT_MSG"
git push

echo "Done: pushed with message:"
echo "  $COMMIT_MSG"
