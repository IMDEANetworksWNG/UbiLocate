#!/bin/bash

cd "$(dirname "$0")"

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

if [ "$rx" = "4" ];then
  rximdea=172
fi
if [ "$rx" = "10" ];then
  rximdea=171
fi
if [ "$rx" = "5" ];then
  rximdea=173
fi
if [ "$rx" = "6" ];then
  rximdea=174
fi
if [ "$rx" = "7" ];then
  rximdea=175
fi


echo ${rximdea}
#ASUS="3 4 5 6 10"
#ASUS="3 ${rx}"
echo ${ASUS}
sleep 2
echo "starting"
#for each in $ASUS ; do
sendcmd -s 192.168.2.3 -p 30000 -c "/jffs/real_time_aod/./gong_2.sh"
sendcmd -s 172.16.1.${rximdea} -p 30000 -c "/jffs/real_time_aod/./gong_2.sh"
#done
sleep 5 

bash kill_process.sh


bash copy_traces_ind.sh ${rx} ${folder}
