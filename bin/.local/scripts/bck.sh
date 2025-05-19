#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# 1) Configuration
# -----------------------------------------------------------------------------
HOST="$(hostname -f)"

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

BACKUP_DATA="/run/media/brubs/Bruno/auto-backup"

LOG_DIR="$XDG_STATE_HOME/backup"

# -----------------------------------------------------------------------------
# 2) Helper Functions
# -----------------------------------------------------------------------------
setup_logging() {
  mkdir -p "$BACKUP_DATA" "$LOG_DIR"
  TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
  LOG_FILE="$LOG_DIR/backup-$TIMESTAMP.log"
  ln -sf "$LOG_FILE" "$LOG_DIR/latest.log"
  echo "===== Backup started at $(date) =====" > "$LOG_FILE"
  echo "Backup started at $(date)"
}

log() {
  local level="$1"
  local message="$2"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

run_step() {
  local step_name="$1"
  local step_func="$2"

  # If ONLY_STEPS is not empty, check if this step should be run
  if [[ ${#ONLY_STEPS[@]} -gt 0 ]]; then
    if ! [[ " ${ONLY_STEPS[*]} " =~ " ${step_name} " ]]; then
      log "INFO" "Skipping step: $step_name"
      return
    fi
  fi

  echo "Running step: $step_name"
  log "INFO" "Running step: $step_name"
  if ! $step_func >>"$LOG_FILE" 2>&1; then
    log "ERROR" "Step failed: $step_name"
    echo "Step failed: $step_name"
    return 1
  fi
  echo "Step completed: $step_name"
}

# -----------------------------------------------------------------------------
# 3) Backup Step Functions
# -----------------------------------------------------------------------------
backup_gdrive_me() {
  log "INFO" "Syncing personal Google Drive"
  rclone sync gdrive_me:/ "$BACKUP_DATA/gdrive_me" --checksum --log-level INFO
}

backup_gdrive_ro() {
  log "INFO" "Syncing read-only Google Drive"
  rclone sync gdrive_ro:/ "$BACKUP_DATA/gdrive_ro" --checksum --log-level INFO
}

backup_obsidian() {
  log "INFO" "Starting Obsidian vault backup"
  
  mkdir -p "$BACKUP_DATA/obsidian-backup"
  rm -rf "$BACKUP_DATA/obsidian-backup/vault"
  cp -r ~/Documents/notes "$BACKUP_DATA/obsidian-backup/vault"

  local VAULT_DIR="$BACKUP_DATA/obsidian-backup/vault"
  cd "$VAULT_DIR" || {
    log "ERROR" "Cannot cd to $VAULT_DIR"
    return 1
  }

  # Stage everything
  git add --all

  # Commit with timestamp (ignore exit code if there's nothing to commit)
  if ! git commit -m "Obsidian vault backup: $(date +'%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1; then
    log "INFO" "No changes to commit for vault at $(date)"
  else
    log "INFO" "Created git commit for vault at $(date)"
  fi

  # Push; on failure log error and set ERR
  if ! git push origin main >/dev/null 2>&1; then
    log "ERROR" "Git push failed for Obsidian vault at $(date)"
    return 1
  else
    log "INFO" "Git push succeeded for Obsidian vault at $(date)"
  fi
}

# -----------------------------------------------------------------------------
# 4) Command Line Arguments
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
# 5) Main Execution
# -----------------------------------------------------------------------------
# Initialize logging
setup_logging

# Define the dispatch table
declare -A STEPS=(
  ["gdrive_me"]="backup_gdrive_me"
  ["gdrive_ro"]="backup_gdrive_ro"
  ["obsidian"]="backup_obsidian"
)

# Run all steps or only specified ones
ERR=0
for step_name in "${!STEPS[@]}"; do
  if ! run_step "$step_name" "${STEPS[$step_name]}"; then
    ERR=1
  fi
done

log "INFO" "Backup finished at $(date) exit=$ERR"
echo "Backup finished at $(date) exit=$ERR"
exit $ERR
