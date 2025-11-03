#!/bin/bash
# Fix cursor theme for all applications

# Load X resources
xrdb -merge ~/.Xresources

# Set environment variables
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

# Update systemd user environment
dbus-update-activation-environment --systemd XCURSOR_THEME XCURSOR_SIZE 2>/dev/null || true

# Set root window cursor
xsetroot -cursor_name left_ptr

# Restart AwesomeWM to apply changes
echo "awesome.restart()" | awesome-client

echo "Cursor theme has been reloaded. You may need to restart some applications (Chrome, Slack, etc.) for changes to take effect."
