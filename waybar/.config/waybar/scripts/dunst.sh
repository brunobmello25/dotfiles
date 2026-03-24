#!/usr/bin/env bash
# ~/.config/waybar/scripts/dunst.sh
# Equivalente ao widget dunst.lua do AwesomeWM

status() {
    paused=$(dunstctl is-paused 2>/dev/null)
    if [ "$paused" = "false" ]; then
        echo '{"text":"🔔","tooltip":"Notificações ativas","class":""}'
    else
        echo '{"text":"🔕","tooltip":"Notificações pausadas","class":"muted"}'
    fi
}

toggle() {
    paused=$(dunstctl is-paused 2>/dev/null)
    if [ "$paused" = "false" ]; then
        dunstctl set-paused true
    else
        dunstctl set-paused false
        notify-send -t 1000 "Notificações ativadas"
    fi
}

case "$1" in
    toggle) toggle ;;
    status|*) status ;;
esac
