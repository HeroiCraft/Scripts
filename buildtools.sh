#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
rev="$mcVer"
noCopy="false"

function move {
if [[ "$noCopy" == "false" ]]; then
  for serverName in $serverList
  do
    if [[ "$serverName" != "bungee" ]]; then
      #Bungee updating is handled by another script
      if [[ -e "spigot-${rev}-patched.jar" ]]; then
        cp -fv "spigot-${rev}-patched.jar" "$HeroiCraftDIR/$serverName/spigot.jar"
      else
        cp -fv "spigot-${rev}.jar" "$HeroiCraftDIR/$serverName/spigot.jar"
      fi
    fi
  done
fi
}

function main {
echo "Starting BuildTools..."
while getopts :pnr: FLAG; do
  case $FLAG in
    n) #No Copy
      noCopy="true"
      echo "Not going to copy new jars"
      ;;
    r) # Specify Revision
      rev="$OPTARG"
      echo "Building for version $OPTARG"
      ;;
    p) # Patch jar with updated MCStats while plugins update
      patchJar="true"
      echo "Patching jar with fixed MCStats"
      ;;
  esac
done
if [[ ! -e BuildTools.jar ]]; then
  cd $mainDir/BuildTools
fi
if [[ -e "spigot-*.jar" ]]; then
  rm spigot-*.jar craftbukkit-*.jar
  echo "Removed old Jars"
fi
trap control_c SIGINT
java -jar BuildTools.jar --rev "$rev" || control_c
echo "Build Complete!"
echo ""
if [[ "$patchJar" == "true" ]]; then
  cp "spigot-${rev}.jar" "spigot-$rev-patched.jar"
  patchStats
fi
if [[ "$noCopy" == "true" ]]; then
  echo "Not copying new jars"
else
  move
fi
}

function control_c {
echo "Stopping build immedietly and not copying"
noCopy="true"
exit 1
}


function patchStats {
if [[ -d "Plugin-Metrics" ]]; then
  cd Plugin-Metrics
else
  git clone https://github.com/Hidendra/Plugin-Metrics.git
  cd Plugin-Metrics
fi
git pull origin master
cd mods/bukkit
cd metrics
mvn clean compile
jar -uf ../../../../spigot-$rev-patched.jar target/classes/org
cd ..
cd metrics-lite
mvn clean compile
jar -uf ../../../../spigot-$rev-patched.jar target/classes/org
}

main "$@"
