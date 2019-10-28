#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
bakDirs="$serverList" # Servers to backup
bakDate="$(date -Iseconds)" # Current date of backup
bakMain="$HOME/backups/HeroiCraft" # Where to put the backup folders
bakOut="$bakMain/$bakDate" # Where to place the zipped files
keepNum=24 # Number of backups to keep

function backup {
  echo "Backing up $bakDirs..."
  sleep 2s
  mkdir -p "$bakOut"

  echo "Backing up MySQL Databases"
  mysqldump -ubackupScript -p$bakPassword -C mc_luckperms > $bakOut/luckperms.sql
  mysqldump -ubackupScript -p$bakPassword -C pex > $bakOut/pex.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_geSuit > $bakOut/geSuit.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_stats > $bakOut/stats.sql
  mysqldump -ubackupScript -p$bakPassword -C mc_prism | gzip -c --rsyncable > $bakOut/prism.sql.gz
  mysqldump -ubackupScript -p$bakPassword -C mc_venturechat | gzip -c --rsyncable $bakOut/venturechat.sql.gz
  echo "Starting server backup"
  sleep 2s
  for serverName in $bakDirs; do
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
    #GZIP="--rsyncable --best" tar -jcvf "$bakOut/${serverName}.tar.bz2" "$serverName"
    if [ "$serverName" != bungee ]; then
      if screen -list | grep -q "mc_$serverName"; then
        screen -S mc_$serverName -X stuff "save-on \n"
        screen -S mc_$serverName -X stuff "say Backup Complete! \n"
      fi
    fi
  done
  touch "$bakOut/date.txt" && echo "$bakDate" >> "$bakOut/date.txt"
  unlink $HOME/backups/recent
  ln -s "$bakOut" "$HOME/backups/recent"
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

function b2Sync {
  echo "B2: Starting Backblaze B2 sync"
  rclone --transfers 32 sync "~/backups/recent" "b2:HeroiCraft-Backups/backups/recent"
}

function nasSync {
  echo "NAS: Syncing backups to buffalo"
  rsync -azP ~/backups/ rsync://10.0.1.115/array1_backups/HCBackup
  if [[ "$?" != 0 ]]; then
    echo "NAS: Sync failed, NAS down?"
  else
    echo "NAS: Sync Complete!"
  fi
}

function megaSync {
  echo "MEGA: Starting Remote sync"
  megarm /Root/HeroiCraftBackups/recent --reload && echo "MEGA: Removed old backup"
  megamkdir /Root/HeroiCraftBackups/recent
  megacopy --local="$HOME/backups/recent/" --remote="/Root/HeroiCraftBackups/recent/" && echo "MEGA: Backup Uploaded"
}

function amznSync {
  echo "AMZN: Starting Amazon Cloud Drive Sync"
  acdcli ul -dr 4 "$(readlink -f ~/backups/recent)" Backups/HeroiCraft && echo "AMZN: Sync Completed"
}

function driveSync {
    rclone copy -vv ~/backups SGDBackups:HCBackup
}

function netSync {
  #nasSync
  driveSync # Unlimited Storage, bandwidth
  #amznSync # Unlimited Storage, bandwidth
  megaSync # 50gb storage, ?? banwidth
  b2Sync # 10gb storage, unlimited upload, 10gb/day dl
}

function main {
  cd $HeroiCraftDIR
  if [ "$1" = backup ]; then
    backup
  elif [ "$1" = delete ]; then
    remOld
  elif [ "$1" = sync ]; then
    netSync
    wait
  else
    backup
    remOld
    if [ `date +%H` -ge 22 ] && [ `date +%H` -le 03 ]; then
      echo "Between 10pm and 2am, syncing to remote"
      #Thanks http://unix.stackexchange.com/q/63636/126262
      netSync
    fi
    wait
  fi
}

main "$@"
