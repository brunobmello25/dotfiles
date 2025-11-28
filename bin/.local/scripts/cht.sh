#!/bin/bash
languages=`echo "odin golang rust lua typescript python" | tr ' ' '\n'`
core_utils=`echo "find mv cp sed grep" | tr ' ' '\n'`

selected=`printf "$languages\n$core_utils" | fzf`

read -p "query: " query

if [[ $languages =~ $selected ]]; then
  curl cht.sh/$selected/`echo $query | tr ' ' '+'` & while [ : ]; do sleep 1; done
else
  curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done
fi

