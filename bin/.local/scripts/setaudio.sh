#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# usage() – print help and exit
usage(){
  cat <<EOF >&2
Usage: $(basename "$0") [--guitar|--default]
Options:
  --guitar     switch to your guitar interface
  --default    switch back to your normal interface
  -h|--help    display this help
EOF
  exit 1
}

# make sure exactly one argument is given
[[ $# -eq 1 ]] || usage

case "$1" in
  -h|--help)
    usage
    ;;

  --guitar)
    NEW_SINK="alsa_output.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo-output"
    NEW_SOURCE="alsa_input.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo-input"
    ;;

  --default)
    NEW_SINK="alsa_output.pci-0000_0b_00.4.analog-stereo"
    NEW_SOURCE="alsa_input.usb-3142_fifine_Microphone-00.iec958-stereo"
    ;;

  *)
    echo "Error: unknown option '$1'" >&2
    usage
    ;;
esac

# 1) set default sink & move all playback streams
pactl set-default-sink "$NEW_SINK"
# for id in $(pactl list short sink-inputs | cut -f1); do
#   pactl move-sink-input "$id" "$NEW_SINK"
# done

# 2) set default source & move all recording streams
pactl set-default-source "$NEW_SOURCE"
# for id in $(pactl list short source-outputs | cut -f1); do
#   pactl move-source-output "$id" "$NEW_SOURCE"
# done

echo "Switched to sink:   $NEW_SINK"
echo "           source: $NEW_SOURCE"
