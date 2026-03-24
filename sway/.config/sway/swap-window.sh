#!/usr/bin/env bash
# Swap focused window with next/prev sibling on the same workspace.
# Usage: swap-window.sh next|prev

DIRECTION="${1:-next}"
TREE=$(swaymsg -t get_tree)

# Get all window con_ids on the focused workspace (in tree order)
IDS=($(echo "$TREE" | jq -r '
  .. | select(.type? == "workspace" and .focused? != true) // empty |
  .. | select(.type? == "workspace") // empty
' 2>/dev/null | head -0; echo "$TREE" | jq -r '
  [.. | select(.type? == "workspace")] |
  [.[] | {ws: .name, nodes: [.. | select(.pid? > 0)]}] |
  .[] | select(.nodes | any(.focused)) |
  .nodes[].id
'))

COUNT=${#IDS[@]}
[ "$COUNT" -le 1 ] && exit 0

# Find focused window id and index
FOCUSED=$(echo "$TREE" | jq -r '.. | select(.focused? == true and .pid? > 0) | .id')
for i in "${!IDS[@]}"; do
  [ "${IDS[$i]}" = "$FOCUSED" ] && IDX=$i && break
done

# Calculate target index with wrapping
if [ "$DIRECTION" = "next" ]; then
  TARGET_IDX=$(( (IDX + 1) % COUNT ))
else
  TARGET_IDX=$(( (IDX - 1 + COUNT) % COUNT ))
fi

swaymsg swap container with con_id "${IDS[$TARGET_IDX]}"
