#!/bin/bash

name=$1

if [ "$name" = "" ]; then
  echo "Missing the ID of the measurements"
  exit 1
fi


# go to the current directory
cd "$(dirname "$0")"

# enable NTP server
./csicollector -p 10000 &

# sleep one second just in case
sleep 1

# create the folder to storage the CSI data
mkdir ../traces

# asus receiver ids
ASUS="4 5"

# the TX id
tx="3"

# remove the phase jumps
echo "remove phase jumps"

for rx in $ASUS ; do
  sshpass -p imdea ssh imdea@192.168.2.${rx} /jffs/csisoftware/./disable_phase_jumps.sh
done

# collect the CSI data
echo "Collecting"
for rx in $ASUS ; do
  sshpass -p imdea ssh imdea@192.168.2.${rx} /jffs/csisoftware/./csirouter -p 10000 -s 192.168.2.105 &  
done

# sleep just in case
sleep 2  

# send 1000 wifi 80MHz packets with 1 spatial stream
echo "Sending"
sshpass -p imdea ssh imdea@192.168.2.${tx} /jffs/LEGACY160/./send.sh 80 1 1000

sleep 1 

# echo kill the collection of the routers
echo "Killing"
for rx in $ASUS ; do
  sshpass -p imdea ssh imdea@192.168.2.${rx} /usr/bin/killall -SIGINT csirouter 
done

# kill the NTP server
killall -9 csicollector

# create the folder to store the csi traces
mkdir ../traces/${name}/

# move everything to traces
mv *.pcap ../traces/${name}/

