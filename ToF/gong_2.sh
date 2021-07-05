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

mkdir traces
mkdir traces/${folder}
for each in $ASUS ; do
  sshpass -p imdea scp imdea@192.168.2.${each}:/tmp/trace${each}.pcap traces/${folder}/trace${each}.pcap
done


#sendcmd -s 192.168.2.3 -p 30000 -c "/jffs/real_time_aod/./gong_2.sh"

#sleep 5 

#bash kill_process.sh

#bash copy_traces.sh ${folder}
