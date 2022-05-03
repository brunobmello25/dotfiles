#!/bin/bash

config_dir="/home/$USER/.config/find-project"
config_file="$config_dir/projects"

assert_file_exists() {
  if ! [ -d $config_dir ]; then
    mkdir -p $config_dir
  fi

  if ! [ -f config_file ]; then
    touch $config_file
  fi
}

if [ $#==0 ]; then
  assert_file_exists
  
  selected=`/usr/bin/cat $config_file | fzf`
  
  dir=`echo $selected | cut -d " " -f 2`

  cd $dir
elif [ $# == 1 ]; then
  echo "tem um argumento"
else
  echo "Invalid arguments. You should either call this script with no arguments to open the projects finder, or call it with \"add\" or \"remove\" arguments"
fi

