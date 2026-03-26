#!/usr/bin/env bash
# Lock screen para Sway/Wayland
# Mostra o wallpaper com efeito de escurecimento (dim)
#
# Dependências: imagemagick (convert), swaylock
#   sudo apt install imagemagick swaylock

WALLPAPER="$HOME/Pictures/wallpapers/WQHD/futuristic_geometric_shapes-wallpaper-3440x1440.jpg"
TMPDIM=/tmp/sway_lock_dim.png

# Aplica escurecimento (50% brightness) no wallpaper
if [ ! -f "$TMPDIM" ] || [ "$WALLPAPER" -nt "$TMPDIM" ]; then
    convert "$WALLPAPER" -fill black -colorize 40% "$TMPDIM"
fi

# Chama swaylock com a imagem escurecida
# -f = fork (não bloqueia o terminal)
# -s fill = escala para preencher a tela (mesmo modo do sway config)
swaylock -f -s fill --image "$TMPDIM"
