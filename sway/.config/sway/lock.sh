#!/usr/bin/env bash
# Lock screen para Sway/Wayland
# Equivalente ao bin/lock.sh do AwesomeWM, adaptado para Wayland
#
# Dependências: grim, imagemagick (convert), swaylock
#   sudo apt install grim imagemagick swaylock
#
# Alternativa mais simples (sem blur): apenas swaylock
# Alternativa com blur nativo: swaylock-effects (não está nos repos do Ubuntu 24.04 — instalar via PPA ou Flatpak)

TMPBG=/tmp/sway_bg.png
TMPBLUR=/tmp/sway_bg_blur.png

# Captura a tela com grim (equivalente ao maim no X11)
grim "$TMPBG"

# Aplica blur (mesmo algoritmo do seu lock.sh original)
convert "$TMPBG" -scale 10% -blur 0x8 -scale 1000% "$TMPBLUR"

# Chama swaylock com a imagem borrada
# -f = fork (não bloqueia o terminal)
swaylock -f --image "$TMPBLUR"

# Limpa temporários
rm -f "$TMPBG" "$TMPBLUR"
