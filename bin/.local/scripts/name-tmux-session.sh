#!/usr/bin/env bash


if [[ $(echo $TMUX) != "" ]]; then
  clear

  printf "Enter a new name for the current session > "
  read -r
  new_name=$REPLY
  tmux rename-session -t "$(tmux display-message -p "#S")" "${new_name}"

  echo "Session renamed to ${new_name}"
else
  echo "You must be in a tmux session to rename it."
fi

