#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found

function main {
for server in $serverList; do
  echo "Updating $server"
  if [[ $server != bungee ]]; then
    cp -arfv "$HeroiCraftDIR/copyToAll/." "$HeroiCraftDIR/$server"
  fi
  rsync -ravz --update --existing $HeroiCraftDIR/copyToSome/ $HeroiCraftDIR/$server
done
rm -rf "$HeroiCraftDIR/copyToAll/"
rm -rf "$HeroiCraftDIR/copyToSome/"
mkdir -p "$HeroiCraftDIR/copyToAll/plugins/"
mkdir -p "$HeroiCraftDIR/copyToSome/plugins/"
cd "$HeroiCraftDIR"

if [[ "$@" != "-n" ]]; then
  echo "Updating all Servers to latest version..."
  updateBungee
  updateSpigot
fi
}

function updateBungee {
  echo "Updating $bungeeType"
  cd "$HeroiCraftDIR/bungee"
  if [[ "$bungeeType" == "waterfall" ]]; then
    wget -N -t 1 https://ci.aquifermc.org/job/Waterfall/lastStableBuild/artifact/Waterfall-Proxy/bootstrap/target/Waterfall.jar -O waterfall.jar
  elif [[ "$bungeeType" == "bungeecord" ]]; then
    wget -N -t 1 http://ci.md-5.net/job/BungeeCord/lastStableBuild/artifact/bootstrap/target/BungeeCord.jar -O bungeecord.jar
  else
    echo "Unknown BungeeCord type: $bungeeType"
  fi
  cd ..
}

function updateSpigot {
  if [[ "$spigotType" == "spigot" ]]; then
    cd "$HeroiCraftDIR/BuildTools"
    wget -N -t 1 https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar
    $HeroiCraftDIR/scripts/buildSpigot.sh
  elif [[ "$spigotType" == "paper" ]]; then
    echo "This must be done manually for now"
    echo "Place the paperclip jar in the CopyToAll folder and it should update"
  else
    echo "Unknown Spigot type: $spigotType"
  fi
}

main "$@"
