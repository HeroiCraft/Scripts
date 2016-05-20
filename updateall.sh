#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found

for server in $serverList; do
  if [[ $server != bungee ]]
  then
    cp -arfv "$HeroiCraftDIR/copyToAll/." "$HeroiCraftDIR/$server"
  fi
  rsync -ravz --update --existing $HeroiCraftDIR/copyToSome/plugins/ $HeroiCraftDIR/$server/plugins/
done
rm -rf "$HeroiCraftDIR/copyToAll/"
rm -rf "$HeroiCraftDIR/copyToSome/"
mkdir -p "$HeroiCraftDIR/copyToAll/plugins/"
mkdir -p "$HeroiCraftDIR/copyToSome/plugins/"
cd "$HeroiCraftDIR"

if [[ "$@" != "-n" ]]; then
  echo "Updating all Servers to latest version..."
  echo "Updating BungeeCord"
  cd bungee
  wget -N -t 1 http://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar
  cd ..

  cd BuildTools
  wget -N -t 1 https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar
  $HeroiCraftDIR/scripts/buildtools.sh
fi
