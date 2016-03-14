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

  echo "Backing up MySQL Databases"
  mysqldump -ubackupScript -p$bakPassword -C pex > $bakOut/pex.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_geSuit > $bakOut/geSuit.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_prism > $bakOut/prism.sql
  echo "Starting server backup"
  for serverName in $bakDirs
  do
    echo "Backing up $serverName"
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

function netSync {
  echo "Syncing backups to network NAS"
  rsync -azP ~/backups/ rsync://10.0.1.115/array1_backups/HCBackup
  if [[ "$?" != 0 ]]; then
    echo "Sync failed, NAS down?"
  else
    echo "Sync Complete!"
  fi
}

function main {
  cd $HeroiCraftDIR
  if [ "$1" = backup ]; then
    backup
  elif [ "$1" = delete ]; then
    remOld
  elif [ "$1" = sync ]; then
    netSync
  else
    backup
    remOld
    netSync
    exit
  fi
}

main "$@"
