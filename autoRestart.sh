#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
#timestamp="$(date +%s)"

function tryBuild {
#lastBuild="$(cat $mainDir/BuildTools/lastbuild.txt)"
runsLeft="$(cat $HeroiCraftDIR/BuildTools/runsLeft.txt)"

if [[ $runsLeft -le 0 ]]; then
  # Every 10 runs of script, run buildtools
  cd $HeroiCraftDIR/BuildTools/
  echo "10" > runsLeft.txt
  #./buildtools.sh
  cd ..
  ./updateall.sh
else
  newRunsLeft="$(expr $runsLeft - 1)"
  echo "$newRunsLeft" > $HeroiCraftDIR/BuildTools/runsLeft.txt
  echo "There are $newRunsLeft runs until the next build of spigot"
fi
}

function stopServers {
cd $HeroiCraftDIR
./stopall.sh
}

function startServers {
cd $HOME
./run.sh
}

function main {
stopServers
tryBuild
if [[ "$@" == "--no-start" ]]; then
  echo ""
  echo "Not restarting Minecraft Servers! Please reboot manually"
  echo ""
else
  startServers
fi
}

main "$@"

