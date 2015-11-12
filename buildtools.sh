#!/bin/bash
source "$HOME/HeroiCraft/scripts/sourceme" || exit 4 # Exit if sourceme isn't found
rev="$mcVer"
noCopy="false"

function move {
  for serverName in $serverList
  do
    if [[ "$serverName" != "bungee" ]]; then
      #Bungee updating is handled by another script
     cp -fv spigot-*.jar "$HeroiCraftDIR/$serverName/spigot.jar"
   fi
 done
}

function main {
  echo "Starting BuildTools..."
  while getopts :nr: FLAG; do
    case $FLAG in
    n) #No Copy
noCopy="true"
echo "Not going to copy new jars"
;;
    r) # Specify Revision
rev="$OPTARG"
echo "Building for version $OPTARG"
;;
esac
done
rm spigot-*.jar
trap control_c SIGINT
java -jar BuildTools.jar --rev "$rev"
echo "Build Complete!"
echo ""
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

main "$@"
