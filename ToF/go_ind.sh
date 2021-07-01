#!/bin/bash

rx=$1
folder=$2

if [ "$rx" = "" ]; then
  echo "Missing the RX"
  exit 1
fi


if [ "$folder" = "" ]; then
  echo "Missing the folder"
  exit 1
fi


#ASUS="3 4 5 6 10"
ASUS="3 ${rx}"
echo ${ASUS}
for each in $ASUS ; do
  sendcmd -s 192.168.2.$each -p 30000 -c "/jffs/real_time_aod/./gong.sh"
done
sleep 5

bash kill_process.sh


bash copy_traces_ind.sh ${rx} ${folder}
