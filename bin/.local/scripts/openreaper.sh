#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ─── adjust to your setup ─────────────────────────────────────────────────────
AUDIO_SWITCH=setaudio.sh
REAPER_CMD=/home/brubs/opt/REAPER/reaper
SWITCH_BACK_DELAY=5    # seconds
# ──────────────────────────────────────────────────────────────────────────────

VERBOSE=0

usage() {
  echo "Usage: $(basename "$0") [-v|--verbose]"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) VERBOSE=1; shift ;;
    -h|--help)    usage ;;
    *)            echo "Unknown option: $1"; usage ;;
  esac
done

if [[ $VERBOSE -eq 1 ]]; then
  exec 3>&1
else
  exec 3>/dev/null
fi

# 1) go to guitar
echo "Switching to guitar audio..." >&3
"$AUDIO_SWITCH" --guitar >/dev/null 2>&1

# 2) fire off Reaper in background
echo "Starting Reaper..." >&3
"$REAPER_CMD" >/dev/null 2>&1 &

# 3) in parallel wait a few seconds and restore default
(
  sleep "$SWITCH_BACK_DELAY"
  echo "Restoring default audio after ${SWITCH_BACK_DELAY}s..." >&3
  "$AUDIO_SWITCH" --default >/dev/null 2>&1
) &

exit 0
