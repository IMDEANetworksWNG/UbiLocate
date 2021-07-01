#!/bin/bash

folder=$1

if [ "$folder" = "" ]; then
  echo "Missing the folder"
  exit 1
fi



cd "$(dirname "$0")"

ASUS="171 172 173 174 175"

echo "starting"

for each in $ASUS ; do
  sendcmd -s 172.16.1.$each -p 30000 -c "/jffs/real_time_aod/./gong_2.sh"
done

sendcmd -s 192.168.2.3 -p 30000 -c "/jffs/real_time_aod/./gong_2.sh"

sleep 5 

bash kill_process.sh

bash copy_traces.sh ${folder}
