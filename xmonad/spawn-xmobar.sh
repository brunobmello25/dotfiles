#!/bin/bash

killall xmobar
xmobar -x 0 /home/brubs/.config/xmobar/xmobarrc &
xmobar -x 1 /home/brubs/.config/xmobar/xmobarrc &
