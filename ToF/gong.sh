#!/bin/bash

cd "$(dirname "$0")"

ASUS="3 4 5 6 10"

for each in $ASUS ; do
  sendcmd -s 192.168.2.$each -p 30000 -c "/jffs/real_time_aod/./gong.sh"
done
