#!/usr/bin/env bash
# where to store the snapshot
TMPBG=/tmp/awesome_bg.png

# grab & blur
maim | convert png:- -scale 10% -blur 0x8 -scale 1000% $TMPBG

# optional: draw a lock icon or overlay text here
# e.g. composite /path/to/lock-icon.png $TMPBG $TMPBG

# finally call i3lock
i3lock --image=$TMPBG
