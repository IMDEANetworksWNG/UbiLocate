#!/bin/bash

# ssh logins
us="imdea"
pw="imdea"

# rx and tx numbers
tx="3"
rxs="4"

name=$1

if [ "$name" = "" ]; then
  echo "Missing the ID of the measurements"
  exit 1
fi

pkts=$2

if [ "$pkts" = "" ]; then
  echo "Missing number of packets to send"
  exit 1
fi

nss=$3
if [ "$nss" = "" ]; then
  echo "Missing number of spatial streams"
  exit 1
fi


# go to the current directory
cd "$(dirname "$0")"

# sleep one second just in case
sleep 1

# create the folder to storage the CSI data
mkdir ../traces

# remove the phase jumps
echo "remove phase jumps"

for rx in $rxs ; do
  sshpass -p ${pw} ssh ${us}@192.168.2.${rx} /jffs/send_periodically/./disable_phase_jumps.sh
done

# collect the CSI data
echo "Collecting"
for rx in $rxs ; do
  sshpass -p ${pw} ssh ${us}@192.168.2.${rx} /jffs/send_periodically/./collectcsi.sh trace.pcap &  
done

# sleep just in case
sleep 2  

# send the # of packets with BW and number of spatial streams 
echo "Sending"
sshpass -p ${pw} ssh ${us}@192.168.2.${tx} /jffs/send_periodically/./send.sh ${pkts} ${nss} 
sleep 5 

echo kill the collection of the routers
echo "Killing"
for rx in $rxs ; do
  sshpass -p ${pw} ssh ${us}@192.168.2.${rx} /usr/bin/killall tcpdump  
done

# create the folder to store the csi traces
mkdir ../traces/${name}/

# move everything to traces
for rx in $rxs ; do
  sshpass -p imdea scp imdea@192.168.2.${rx}:/tmp/trace.pcap ../traces/${name}/trace${rx}.pcap
done

#
