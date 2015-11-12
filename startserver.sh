#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
clear

if [[ -z $1 ]]; then
  echo No Server Provided
  echo "Do ./${0##*/} <servername> to run"
  exit 1
else
  serverName=$1
fi

function restart {
	echo "Do you want to Restart? [y/N]"
	read restart
	if [ "$restart" == y ]; then
		startServer $serverName
	else
		exit
	fi
}

function startServer {
	if [ "$serverName" == bungee ]; then
		xtitle "Minecraft Server: BungeeCord"
		cd $HeroiCraftDIR/$serverName/
    rm plugins/CommandSync/data.txt
		echo "Starting $servernerName"
		java -jar BungeeCord.jar
		echo
		restart
	else
		xtitle "Minecraft Server: $serverName"
		cd $HeroiCraftDIR/$serverName/
    rm plugins/CommandSync/data.txt
		rm plugins/CraftBukkitUpToDate/CraftBukkitUpToDate.sav
		echo "Starting $serverName..."
		echo
		java -server -Xmx1G \
      -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -XX:+DisableExplicitGC -XX:G1HeapRegionSize=4M -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AggressiveOpts \
		-Djava.net.preferIPv4Stack=true \
		-jar spigot.jar --log-strip-color
		echo
		restart
	fi
}

startServer $serverName
