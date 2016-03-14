#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
msg="$@"
reason="Get to a safe place, and prepare for the server to stop!"
if [[ -n $msg ]]; then
  reason="$msg"
fi
if [[ $msg == '-f' ]]; then
  quick=true
fi

function stopall {
echo "Exiting with reason: '$reason' in 5 seconds..."
qsleep 5s 0s
nc -w15 -vz localhost 25566
if [[ "$?" == "0" ]]; then
  echo "Stopping all servers!"
  # Warn the Players
  screen -S mc_hub -X stuff 'sync console all title @a title [{"text":"Shutting down soon!","color":"red","bold":"true"}] \n'
  screen -S mc_hub -X stuff "sync console all title @a subtitle [{'text':'$reason','color':'light_purple','italic':'true'}] \n"
  qsleep 15s 0s
  # Use the hub to stop all servers
  # If hub isn't up, this will fail horribly
  screen -S mc_hub -X stuff "sync console all save-all \n"
  screen -S mc_hub -X stuff "sync console all stop \n"
  qsleep 5s 1s
  screen -S mc_bungee -X stuff "end \n"
  qsleep 15s 10s
  for screen in $serverList
  do
    screen -S mc_$screen -X stuff "\n \n exit"
    sleep .5s
    screen -S mc_$screen -X quit
  done
  echo "Stopped all servers and exited screens"
else
  echo "Cannot detect a responding hub server"
  echo "It is unsafe to shut down, aborting"
  exit 1
fi
}

function qsleep {
if [[ $quick == true ]]; then
  echo "Replacing $1 sleep with $2 due to Quick Shutdown"
  sleep $2
else
  sleep $1
fi
}


stopall "$@"

