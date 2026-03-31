#!/usr/bin/env bash
# ~/.config/sway/autostart.sh
# Equivalente ao autostart.lua + ~/.screenlayout/ do AwesomeWM
# Executado via: exec ~/.config/sway/autostart.sh

USER=$(whoami)

# Detecta monitor externo via swaymsg
external_connected() {
    swaymsg -t get_outputs | grep '"name":' | grep -qv '"eDP-'
}

# Layout de monitor por usuário
# Equivalente aos scripts em ~/.screenlayout/
if [ "$USER" = "bruno.mello" ]; then
    if external_connected; then
        # plugged.sh: eDP-1 1920x1200 @(0,1320), HDMI-1 3440x1440R primary @(1920,1080), DP-3 1920x1080 @(2177,0)
        # Nota: no Wayland HDMI-1 → HDMI-A-1. Verifique com: swaymsg -t get_outputs
        swaymsg output eDP-1 enable mode 1920x1200 scale 1.2 position 318 1329
        swaymsg output HDMI-A-1 enable mode 3440x1440 position 1920 1080
        swaymsg output DP-3 enable mode 1920x1080 position 2682 0
    else
        # unplugged.sh: eDP-1 1920x1200 scale 0.8
        # Nota: sway usa scale inverso ao xrandr — scale 0.8 no xrandr ≈ scale 0.8 no sway
        swaymsg output eDP-1 enable mode 1920x1200 scale 1.2 position 0 0
        swaymsg output HDMI-A-1 disable 2>/dev/null || true
        swaymsg output DP-3 disable 2>/dev/null || true
    fi
elif [ "$USER" = "brubs" ]; then
    # desktop.sh: HDMI-0 1920x1080 @(760,0), DP-0 3440x1440 primary @(0,1080)
    # Nota: nomes podem ser HDMI-A-1/DP-1 no Wayland. Verifique com: swaymsg -t get_outputs
    swaymsg output HDMI-A-1 enable mode 1920x1080 position 760 0
    swaymsg output DP-1 enable mode 3440x1440 position 0 1080
fi

# xdg-autostart (equivalente ao dex-autostart)
if command -v dex >/dev/null 2>&1; then
    dex --autostart --environment sway 2>/dev/null &
fi
