#!/usr/bin/env bash
# ~/.config/sway/autostart.sh
# Equivalente ao autostart.lua + ~/.screenlayout/ do AwesomeWM
# Executado via: exec ~/.config/sway/autostart.sh

# Monitor layout is now applied by monitor-layout.sh (exec_always, survives reload)

# Renomeia workspaces iniciais para "output:1"
# Sway cria workspaces "1", "2", "3" (um por output) por padrão.
# Todos devem virar "output:1" para que cada tela inicie no workspace 1.
for entry in $(swaymsg -t get_workspaces | jq -r '.[] | "\(.name)|\(.output)"'); do
    name="${entry%%|*}"
    output="${entry##*|}"
    if [[ "$name" != *:* ]]; then
        swaymsg "rename workspace \"$name\" to \"${output}:1\""
    fi
done

# xdg-autostart (equivalente ao dex-autostart)
if command -v dex >/dev/null 2>&1; then
    dex --autostart --environment sway 2>/dev/null &
fi
