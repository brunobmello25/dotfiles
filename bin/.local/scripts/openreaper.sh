#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ─── adjust to your setup ─────────────────────────────────────────────────────
AUDIO_SWITCH=setaudio.sh
REAPER_CMD=/home/brubs/opt/REAPER/reaper
SWITCH_BACK_DELAY=5    # seconds
# ──────────────────────────────────────────────────────────────────────────────

# 1) go to guitar (silence all output)
"$AUDIO_SWITCH" --guitar >/dev/null 2>&1

# 2) fire off Reaper in background (silence its output too)
"$REAPER_CMD" >/dev/null 2>&1 &

# 3) in parallel wait a few seconds and restore default (silenced)
(
  sleep "$SWITCH_BACK_DELAY"
  "$AUDIO_SWITCH" --default >/dev/null 2>&1
) &

exit 0
