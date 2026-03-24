#!/usr/bin/env bash
# ~/.config/waybar/scripts/vpn.sh
# Equivalente ao widget vpn.lua do AwesomeWM (warp-cli)

status=$(warp-cli status 2>/dev/null)

if echo "$status" | grep -q "Connected"; then
    echo '{"text":"🌐","tooltip":"VPN: Conectada","class":"connected"}'
else
    echo '{"text":"🔒","tooltip":"VPN: Desconectada","class":""}'
fi
