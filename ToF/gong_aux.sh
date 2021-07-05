#!/bin/bash

ASUS="3 4"

echo "starting"

for each in $ASUS ; do
  sendcmd -s 192.168.2.$each -p 30000 -c "/jffs/tofsoftware/./starttxrx80fastng.sh" &
done


#sendcmd -s 192.168.2.3 -p 30000 -c "/jffs/real_time_aod/./gong_2.sh"

#sleep 5 

#bash kill_process.sh

#bash copy_traces.sh ${folder}
