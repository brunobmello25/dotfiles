#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

setxkbmap -layout us -variant intl
run picom --config $HOME/.config/picom/picom.conf --experimental-backends
run kdeconnect-indicator
run mictray
sleep 0.2 && nitrogen --restore
