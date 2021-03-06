#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
echo "Starting HeroiCraft Servers!"
no_window="true"
cd $HeroiCraftDIR

function mc_server {
cd $HeroiCraftDIR
echo "Waiting for Minecraft: $1 to start..."
bgsc mc_$1
sleep .1
screen -S mc_$1 -X stuff " ./startserver.sh $1\n"
sleep .1
if [[ "$no_window" != "true" ]]; then
  gnome-terminal --command="screen -r mc_$1"
fi
cd "$HeroiCraftDIR"
sleep 5s
}

function main {
if [[ -z "$1" ]]; then
  if [[ ! -a "$HOME/.noStart" ]]; then
    for serverName in $serverList; do
      mc_server $serverName
    done
  else
    echo "Not Starting, .noStart exists"
  fi
else
  mc_server "$1"
fi
}

main "$@"
