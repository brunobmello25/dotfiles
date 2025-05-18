#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# 1) Configuration
# -----------------------------------------------------------------------------
HOST="$(hostname -f)"

# XDG dirs (with fallbacks)
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Where to keep the local mirror (inside your data dir)
BACKUP_DATA="/run/media/brubs/Bruno/auto-backup"

# Where to put logs
LOG_DIR="$XDG_STATE_HOME/backup"

# If your secondary HDD is mounted at ~/Backup, mirror goes there:
# (you may skip this if you want everything under $BACKUP_DATA)
# BACKUP_ROOT="$HOME/Backup"  

# -----------------------------------------------------------------------------
# 2) Prepare timestamped log file
# -----------------------------------------------------------------------------
mkdir -p "$BACKUP_DATA" "$LOG_DIR"

TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/backup-$TIMESTAMP.log"

# keep a "latest.log" symlink for quick access
ln -sf "$LOG_FILE" "$LOG_DIR/latest.log"

# Kick off the log: use ">" so if we re-run with the same timestamp
# it starts fresh.  Subsequent writes should use ">>".
echo "===== Backup started at $(date) =====" > "$LOG_FILE"

ERR=0

# -----------------------------------------------------------------------------
# 3) Helper to wrap each step
# -----------------------------------------------------------------------------
run_step() {
  local cmd="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $cmd" >> "$LOG_FILE"
  if ! eval "$cmd" >>"$LOG_FILE" 2>&1; then
    echo "[ERROR] step failed: $cmd" >> "$LOG_FILE"
    ERR=1
  fi
}

# -----------------------------------------------------------------------------
# 4) Sync Google Drive(s)
# -----------------------------------------------------------------------------
run_step "rclone sync gdrive_me:/   $BACKUP_DATA/gdrive_me   --log-level INFO"
run_step "rclone sync gdrive_ro:/   $BACKUP_DATA/gdrive_ro   --log-level INFO"

# -----------------------------------------------------------------------------
# 5) Obsidian vault copy + git push
# -----------------------------------------------------------------------------
mkdir -p "$BACKUP_DATA/obsidian-backup"
rm -rf  "$BACKUP_DATA/obsidian-backup/vault"
cp -r ~/Documents/notes "$BACKUP_DATA/obsidian-backup/vault"

VAULT_DIR="$BACKUP_DATA/obsidian-backup/vault"
(
  cd "$VAULT_DIR" || {
    echo "[ERROR] Cannot cd to $VAULT_DIR" >> "$LOG_FILE"
    ERR=1
    exit 1
  }

  # Stage everything
  git add --all

  # Commit with timestamp (ignore exit code if there's nothing to commit)
  if ! git commit -m "Obsidian vault backup: $(date +'%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1; then
    echo "[INFO] No changes to commit for vault at $(date)" >> "$LOG_FILE"
  else
    echo "[INFO] Created git commit for vault at $(date)" >> "$LOG_FILE"
  fi

  # Push; on failure log error and set ERR
  if ! git push origin main >/dev/null 2>&1; then
    echo "[ERROR] Git push failed for Obsidian vault at $(date)" >> "$LOG_FILE"
    ERR=1
  else
    echo "[INFO] Git push succeeded for Obsidian vault at $(date)" >> "$LOG_FILE"
  fi
)

# # -----------------------------------------------------------------------------
# # 6) Sync your Obsidian vault
# # -----------------------------------------------------------------------------
# # change path to your real vault if different
# run_step "rsync -a --delete \$HOME/Documents/notes/  $BACKUP_DATA/obsidian/"
#
# # -----------------------------------------------------------------------------
# # 7) Sync Google Photos
# # -----------------------------------------------------------------------------
# run_step "rclone sync gphotos_me:/   $BACKUP_DATA/gphotos_me   --log-level INFO"
# run_step "rclone sync gphotos_mom:/  $BACKUP_DATA/gphotos_mom  --log-level INFO"
#
# # -----------------------------------------------------------------------------
# # 8) Push the local mirror up to BackBlaze B2
# # -----------------------------------------------------------------------------
# run_step "rclone sync $BACKUP_DATA/   b2:yourBucketName/backups/   --log-level INFO"

echo "===== Backup finished at $(date) exit=$ERR =====" >> "$LOG_FILE"
exit $ERR
