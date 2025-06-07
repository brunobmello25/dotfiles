#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ─── adjust to your setup ─────────────────────────────────────────────────────
AUDIO_SWITCH=setaudio.sh
REAPER_CMD=/home/brubs/opt/REAPER/reaper
SWITCH_BACK_DELAY=5    # seconds
# ──────────────────────────────────────────────────────────────────────────────

echo "banana"
# 1) go to guitar
"$AUDIO_SWITCH" --guitar

echo "a"
# 2) fire off Reaper in background
"$REAPER_CMD" &
echo "b"

# 3) in parallel wait a few seconds and restore default
(
  sleep "$SWITCH_BACK_DELAY"
  "$AUDIO_SWITCH" --default
) &
echo "c"

# 4) done – your shell / launcher is free immediately
exit 0
