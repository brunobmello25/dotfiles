#!/bin/bash

# Get the current tmux session name
SESSION_NAME=$(tmux display-message -p '#S')

if [ -z "$SESSION_NAME" ]; then
    echo "Error: Not running inside a tmux session"
    exit 1
fi

echo "Current tmux session: $SESSION_NAME"
echo "Enter window names (press Enter with empty string to stop):"

while true; do
    read -p "Window name: " window_name
    
    # Check if input is empty
    if [ -z "$window_name" ]; then
        echo "Stopping..."
        break
    fi
    
    # Create new window with the given name (in background)
    tmux new-window -d -t "$SESSION_NAME" -n "$window_name"
    echo "Created window: $window_name"
done

echo "Done!"