#!/bin/bash

# ssh logins
us="imdea"
pw="imdea"

devs="3 4"

echo "Reloading the devices"
for dev in $devs ; do
  sshpass -p ${pw} ssh ${us}@192.168.2.${dev} /jffs/tofsoftware/./config.sh
done

