#!/bin/bash

assert_file_exists() {
  if ! [ -d $1 ]; then
    mkdir -p $1
  fi
  
  if ! [ -f $2 ]; then
    touch $2
  fi
}

fp() {
  config_dir="/home/$USER/.config/find-project"
  config_file="$config_dir/projects"

  if [[ $# == 0 ]]; then
    assert_file_exists $config_dir $config_file
    
    selected=`/usr/bin/cat $config_file | fzf`

    dir=`echo $selected | cut -d " " -f 2`

    if [[ $dir != "" ]]; then
      cd $dir
    fi
    clear
  elif [[ $# == 1 && $1 == 'add' ]]; then
    assert_file_exists $config_dir $config_file
    
    current_full_path_name=${PWD}
    
    grep -vx ${PWD} $config_file > temp && mv temp $config_file 
    echo $current_full_path_name >> $config_file
  elif [[ $# == 1 && $1 == 'rm' ]]; then
    grep -vx ${PWD} $config_file > temp && mv temp $config_file 
  else
    echo "Invalid arguments. You should either call this script with no arguments to open the projects finder, or call it with \"add\" or \"remove\" arguments"
  fi
}
