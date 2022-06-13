#!/bin/bash

if [[ $(echo $TMUX) != "" ]]; then
  new_name=${PWD##*/}
  tmux rename-session -t "$(tmux display-message -p "#S")" "${new_name}"
  clear
fi

