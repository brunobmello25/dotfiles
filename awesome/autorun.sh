#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

setxkbmap us -option compose:ralt
xrandr --output DVI-D-0 --off --output DP-0 --primary --mode 1920x1080 --pos 0x1080 --rotate normal --output DP-1 --off --output HDMI-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-5 --off
run picom -b --config ~/.config/picom/picom.conf
sleep 0.5 && nitrogen --restore
