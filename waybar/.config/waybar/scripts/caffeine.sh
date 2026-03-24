#!/usr/bin/env bash
# ~/.config/waybar/scripts/caffeine.sh
# Equivalente ao widget caffeine.lua do AwesomeWM
# Em Sway, "caffeine" = matar/iniciar o swayidle

LOCKFILE="/tmp/waybar-caffeine-off"

status() {
    if [ -f "$LOCKFILE" ]; then
        echo '{"text":"☕","tooltip":"Screensaver desativado (caffeine on)","class":"active"}'
    else
        echo '{"text":"🌙","tooltip":"Screensaver ativo","class":""}'
    fi
}

toggle() {
    if [ -f "$LOCKFILE" ]; then
        # Reativa swayidle
        rm -f "$LOCKFILE"
        # Reinicia swayidle (o exec do config.sway já o definiu — aqui relança se morto)
        pkill -x swayidle 2>/dev/null
        swayidle -w \
            timeout 300  'swaylock -f' \
            timeout 600  'swaymsg "output * dpms off"' \
            resume       'swaymsg "output * dpms on"' \
            before-sleep 'swaylock -f' &
        notify-send -t 2000 "DPMS/Screensaver ativado"
    else
        # Desativa swayidle (caffeine mode)
        touch "$LOCKFILE"
        pkill -x swayidle 2>/dev/null
        notify-send -t 2000 "DPMS/Screensaver desativado"
    fi
}

case "$1" in
    toggle) toggle ;;
    status|*) status ;;
esac
