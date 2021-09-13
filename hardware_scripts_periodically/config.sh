#!/bin/bash
# number of spatial stream

# ssh logins
us="imdea" # change it
ps="imdea" # change it

# rx and tx numbers
tx="3"
rxs="4"

nss=$1

if [ "$nss" = "" ]; then
  echo "Missing number of spatial streams"
  exit 1
fi


echo "Setting up the transmitter"
sshpass -p ${ps} ssh ${us}@192.168.2.${tx} /jffs/send_periodically/./config.sh

echo "Setting up the receiver"

for rx in $rxs ; do
  sshpass -p ${ps} ssh ${us}@192.168.2.${rx} /jffs/send_periodically/config_rx.sh ${nss}
done


