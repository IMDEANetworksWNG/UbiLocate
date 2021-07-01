#!/bin/bash

echo "Reloading the router 3"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/real_time_aod/./reload.sh

echo "Config the router 3"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/real_time_aod/./config.sh

echo "rx 3"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/ToF_2/./start_cmd.sh
sshpass -p imdea ssh imdea@192.168.2.3 /usr/sbin/iptables -F
