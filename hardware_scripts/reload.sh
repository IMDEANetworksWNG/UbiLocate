#!/bin/bash
echo "Reloading the transmitter"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/LEGACY160/./reload.sh

ASUS="4 5"

echo "Reloading the receivers"
for rx in $ASUS ; do
  sshpass -p imdea ssh imdea@192.168.2.${rx} /jffs/csisoftware/./reload.sh
done

