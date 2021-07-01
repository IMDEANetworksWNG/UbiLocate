#!/bin/bash

ASUS="4 5"

for each in $ASUS ; do
  sendcmd -s 192.168.2.$each -p 30000 -c "/jffs/real_time_aod/./go.sh"
done
