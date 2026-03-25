#!/bin/bash
# Per-output workspaces for sway (AwesomeWM-like behavior)
# Each output gets its own independent set of workspaces 1-9.
#
# Usage:
#   workspace.sh switch <n>    — switch to workspace n on focused output
#   workspace.sh move <n>      — move container to workspace n on focused output
#   workspace.sh next          — next non-empty workspace on focused output
#   workspace.sh prev          — prev non-empty workspace on focused output

ACTION="$1"
NUM="$2"

# Get focused output name
FOCUSED_OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')

# Workspace name format: "output:number"
ws_name() {
    echo "${FOCUSED_OUTPUT}:${1}"
}

case "$ACTION" in
    switch)
        swaymsg workspace "$(ws_name "$NUM")"
        ;;
    move)
        swaymsg move container to workspace "$(ws_name "$NUM")"
        ;;
    next|prev)
        # Get current workspace name on this output
        CURRENT=$(swaymsg -t get_workspaces | jq -r ".[] | select(.focused) | .name")
        # Extract current number (after the colon), default to 1
        CURRENT_NUM=${CURRENT##*:}
        CURRENT_NUM=${CURRENT_NUM:-1}

        # Get list of non-empty workspaces on this output, sorted
        OCCUPIED=$(swaymsg -t get_workspaces | jq -r \
            "[.[] | select(.output == \"$FOCUSED_OUTPUT\")] | sort_by(.name) | .[].name")

        # Build array of occupied workspace numbers
        NUMS=()
        for ws in $OCCUPIED; do
            n=${ws##*:}
            NUMS+=("$n")
        done

        # If no occupied workspaces, stay put
        if [ ${#NUMS[@]} -eq 0 ]; then
            exit 0
        fi

        # Find current index in occupied list
        IDX=-1
        for i in "${!NUMS[@]}"; do
            if [ "${NUMS[$i]}" = "$CURRENT_NUM" ]; then
                IDX=$i
                break
            fi
        done

        # Calculate next/prev index with wrapping
        LEN=${#NUMS[@]}
        if [ "$ACTION" = "next" ]; then
            NEW_IDX=$(( (IDX + 1) % LEN ))
        else
            NEW_IDX=$(( (IDX - 1 + LEN) % LEN ))
        fi

        swaymsg workspace "$(ws_name "${NUMS[$NEW_IDX]}")"
        ;;
esac
