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
# 2) Parse command line arguments
# -----------------------------------------------------------------------------
ONLY_STEPS=()

print_usage() {
  echo "Usage: $0 [--only STEP1,STEP2,...]"
  echo
  echo "Available steps:"
  echo "  gdrive_me    - Sync personal Google Drive"
  echo "  gdrive_ro    - Sync read-only Google Drive"
  echo "  obsidian     - Backup Obsidian vault"
  echo
  echo "Example: $0 --only gdrive_me,obsidian"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --only)
      if [[ -z $2 ]]; then
        echo "Error: --only requires a comma-separated list of steps"
        print_usage
      fi
      IFS=',' read -ra ONLY_STEPS <<< "$2"
      shift 2
      ;;
    *)
      echo "Error: Unknown option $1"
      print_usage
      ;;
  esac
done

# -----------------------------------------------------------------------------
# 3) Prepare timestamped log file
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
# 4) Helper to wrap each step
# -----------------------------------------------------------------------------
run_step() {
  local step_name="$1"
  local cmd="$2"

  # If ONLY_STEPS is not empty, check if this step should be run
  if [[ ${#ONLY_STEPS[@]} -gt 0 ]]; then
    if ! [[ " ${ONLY_STEPS[*]} " =~ " ${step_name} " ]]; then
      echo "[INFO] Skipping step: $step_name" >> "$LOG_FILE"
      return
    fi
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running step: $step_name" >> "$LOG_FILE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Command: $cmd" >> "$LOG_FILE"
  if ! eval "$cmd" >>"$LOG_FILE" 2>&1; then
    echo "[ERROR] step failed: $cmd" >> "$LOG_FILE"
    ERR=1
  fi
}

# -----------------------------------------------------------------------------
# 5) Sync Google Drive(s)
# -----------------------------------------------------------------------------
run_step "gdrive_me" "rclone sync gdrive_me:/ $BACKUP_DATA/gdrive_me --checksum --log-level INFO"
run_step "gdrive_ro" "rclone sync gdrive_ro:/ $BACKUP_DATA/gdrive_ro --checksum --log-level INFO"

# -----------------------------------------------------------------------------
# 6) Obsidian vault copy + git push
# -----------------------------------------------------------------------------
backup_obsidian() {
  mkdir -p "$BACKUP_DATA/obsidian-backup"
  rm -rf "$BACKUP_DATA/obsidian-backup/vault"
  cp -r ~/Documents/notes "$BACKUP_DATA/obsidian-backup/vault"

  local VAULT_DIR="$BACKUP_DATA/obsidian-backup/vault"
  cd "$VAULT_DIR" || {
    echo "[ERROR] Cannot cd to $VAULT_DIR" >> "$LOG_FILE"
    ERR=1
    return 1
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
}

run_step "obsidian" "backup_obsidian"

# # -----------------------------------------------------------------------------
# # 7) Sync your Obsidian vault
# # -----------------------------------------------------------------------------
# # change path to your real vault if different
# run_step "rsync -a --delete \$HOME/Documents/notes/  $BACKUP_DATA/obsidian/"
#
# # -----------------------------------------------------------------------------
# # 8) Sync Google Photos
# # -----------------------------------------------------------------------------
# run_step "rclone sync gphotos_me:/   $BACKUP_DATA/gphotos_me   --log-level INFO"
# run_step "rclone sync gphotos_mom:/  $BACKUP_DATA/gphotos_mom  --log-level INFO"
#
# # -----------------------------------------------------------------------------
# # 9) Push the local mirror up to BackBlaze B2
# # -----------------------------------------------------------------------------
# run_step "rclone sync $BACKUP_DATA/   b2:yourBucketName/backups/   --log-level INFO"

echo "===== Backup finished at $(date) exit=$ERR =====" >> "$LOG_FILE"
exit $ERR
