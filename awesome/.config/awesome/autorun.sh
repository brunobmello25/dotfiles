#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

setxkbmap -layout us -variant intl
# xrandr --output DVI-D-0 --off --output DP-0 --primary --mode 1920x1080 --pos 0x1080 --rotate normal --output DP-1 --off --output HDMI-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-5 --off
run picom --config $HOME/.config/picom/picom.conf --experimental-backends
run kdeconnect-indicator
run mictray
sleep 0.5 && nitrogen --restore
