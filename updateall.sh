#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
echo "Updating all Servers to latest version..."
echo "Updating BungeeCord"
cd bungee
wget -N -t 1 http://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar
cd ..

for server in $serverList
do
  cd "$HeroiCraftDIR/copyToAll"
  cp -rfv * "$HeroiCraftDIR/$server"
done
rm -rf "$HeroiCraftDIR/copyToAll/"
mkdir -p "$HeroiCraftDIR/copyToAll/plugins/"
cd "$HeroiCraftDIR"

cd BuildTools
wget -N -t 1 https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar
./buildtools.sh
