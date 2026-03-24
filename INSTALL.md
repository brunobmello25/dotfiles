# Guia de instalação — Sway no Ubuntu 24.04

# Migração a partir do AwesomeWM

## 1. Instalar pacotes

```bash
sudo apt install \
  sway swayidle swaylock \
  waybar \
  xdg-desktop-portal-wlr \
  grim slurp grimshot \
  imagemagick \
  rofi \
  alacritty \
  dunst \
  nm-applet \
  copyq \
  playerctl \
  brightnessctl \
  lxpolkit \
  dex \
  foot  # terminal leve alternativo (opcional)
```

## 2. Instalar os arquivos

```bash
# Sway
mkdir -p ~/.config/sway/
cp config       ~/.config/sway/config
cp lock.sh      ~/.config/sway/lock.sh
cp autostart.sh ~/.config/sway/autostart.sh
chmod +x ~/.config/sway/lock.sh ~/.config/sway/autostart.sh

# Waybar
mkdir -p ~/.config/waybar/scripts/
cp waybar/config.jsonc  ~/.config/waybar/config.jsonc
cp waybar/style.css     ~/.config/waybar/style.css
cp waybar/scripts/*.sh  ~/.config/waybar/scripts/
chmod +x ~/.config/waybar/scripts/*.sh
```

## 3. Descobrir nomes dos outputs (monitores)

```bash
swaymsg -t get_outputs
# Substitua "eDP-1" e "HDMI-A-1" nos arquivos config e autostart.sh
# pelos nomes reais retornados pelo comando acima.
```

## 4. Descobrir app_id das janelas Wayland

Para criar regras de floating para apps específicos:

```bash
# Com a janela aberta:
swaymsg -t get_tree | grep -i app_id
# ou instale sway-contrib e use:
# swaymsg -t get_tree | python3 -m json.tool | grep app_id
```

## 5. Iniciar o Sway

No TTY (fora de sessão gráfica):

```bash
sway
```

Ou configure o gerenciador de login (GDM, LightDM) para oferecer "Sway" como opção de sessão.

## 6. Diferenças importantes em relação ao AwesomeWM

| Recurso AwesomeWM           | Equivalente Sway                          |
|-----------------------------|-------------------------------------------|
| Tags (1-9)                  | Workspaces (1-9) — mesmo comportamento    |
| Layout tile                 | splith (padrão)                           |
| Layout max                  | tabbed                                    |
| Layout threecolumn (custom) | Não existe — use splith com 3 janelas     |
| Minimize ($mod+n)           | Scratchpad ($mod+n / $mod+Ctrl+n)         |
| Maximize ($mod+m)           | Fullscreen ($mod+m)                       |
| Focus byidx                 | focus next/prev sibling                   |
| Tag history (Escape)        | workspace back_and_forth                  |
| Tab por tags não-vazias     | workspace next/prev (passa por todas)     |
| picom (compositor)          | Sway tem compositor embutido              |
| xrandr (monitor setup)      | swaymsg output / arquivo config           |
| setxkbmap                   | input config no sway/config               |
| i3lock                      | swaylock                                  |
| maim (screenshot)           | grim                                      |
| flameshot                   | grimshot gui (ou grim + slurp)            |

## 7. Screen share no Wayland (o objetivo principal!)

Para screen share funcionar no Chrome dentro do Sway:

```bash
# Instalar o portal correto
sudo apt install xdg-desktop-portal-wlr

# Variável de ambiente necessária (adicione ao ~/.profile ou ~/.zshenv)
export XDG_CURRENT_DESKTOP=sway
```

O Chrome em Wayland nativo usa o protocolo pipewire para captura de tela,
que é nativo e muito mais eficiente que a captura via XWayland.

## 8. Notas sobre flameshot

O flameshot tem suporte experimental ao Wayland. Se quiser manter:

```bash
# Force modo Wayland no flameshot
XDG_SESSION_TYPE=wayland flameshot gui
```

Ou substitua por `grimshot gui` que é nativo Wayland.
