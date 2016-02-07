#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
bakDirs="$serverList" # Servers to backup
bakDate="$(date +%m-%d-%Y_%I:%M%P)" # Current date of backup
bakMain="$HOME/backups/HeroiCraft" # Where to put the backup folders
bakOut="$bakMain/$bakDate" # Where to place the zipped files
keepNum=48 # Number of backups to keep

function backup {
  echo "Backing up $bakDirs..."
  sleep 2s
  mkdir -p "$bakOut"

  echo "Backing up PEX Database"
  mysqldump -ubackupScript -p$bakPassword -C pex > $bakOut/pex.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_geSuit > $bakOut/geSuit.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_prism > $bakOut/prism.sql
  echo "Starting server backup"
  for serverName in $bakDirs
  do
    if [ "$serverName" != bungee ]; then
      if screen -list | grep -q "mc_$serverName"; then
        screen -S mc_$serverName -X stuff "say Backing up the server, there may be lag \n"
        screen -S mc_$serverName -X stuff "save-off \n"
        screen -S mc_$serverName -X stuff "save-all \n"
        sleep 6s
      fi
    fi
    lrztar -O $bakOut/ $serverName
    if [ "$serverName" != bungee ]; then
      if screen -list | grep -q "mc_$serverName"; then
        screen -S mc_$serverName -X stuff "save-on \n"
        screen -S mc_$serverName -X stuff "say Backup Complete! \n"
      fi
    fi
  done
  echo "Backup Complete!"
}

function remOld {
  echo "Removing old backups..."
  sleep 5s
  cd $bakMain
  if [ "$(find * -maxdepth 0 -type d | wc -l)" -gt "$keepNum" ]; then
    oldDir=$(ls -lt | grep '^d' | tail -1  | tr " " "\n" | tail -1)
    echo "Removing $oldDir..."
    sleep 5s
    rm -rf $oldDir
  else
    echo "Less than $keepNum backups, not removing any"
  fi
}

function main {
  cd $HeroiCraftDIR
  if [ "$1" = backup ]; then
    backup
  elif [ "$1" = delete ]; then
    remOld
  else
    backup
    remOld
    exit
  fi
}

main "$@"
