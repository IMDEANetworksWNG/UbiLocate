#!/bin/bash

folder=$1

if [ "$folder" = "" ]; then
  echo "Missing the folder"
  exit 1
fi



cd "$(dirname "$0")"


ASUS="3 4"

echo "starting"

lastdev=${ASUS: -1}
for each in $ASUS ; do
  if [ $each = $lastdev ];
  then
    sendcmd -s 192.168.2.$each -p 30000 -c "/jffs/tofsoftware/./starttxrx80fastng.sh" 
  else
    sendcmd -s 192.168.2.$each -p 30000 -c "/jffs/tofsoftware/./starttxrx80fastng.sh" &
  fi
done

# save the traces
mkdir traces
mkdir traces/${folder}
for each in $ASUS ; do
  sshpass -p imdea scp imdea@192.168.2.${each}:/tmp/trace${each}.pcap traces/${folder}/trace${each}.pcap
done

