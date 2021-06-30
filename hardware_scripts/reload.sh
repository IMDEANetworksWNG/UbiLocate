#!/bin/bash

# ssh logins
us="imdea"
pw="imdea"

tx="3"
rxs="4"
echo "Reloading the transmitter"
sshpass -p ${pw} ssh ${us}@192.168.2.${tx} /jffs/LEGACY160/./reload.sh


echo "Reloading the receivers"
for rx in $rxs ; do
  sshpass -p ${pw} ssh ${us}@192.168.2.${rx} /jffs/csisoftware/./reload.sh
done

