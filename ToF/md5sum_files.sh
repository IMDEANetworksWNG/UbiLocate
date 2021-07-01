#!/bin/bash
echo "Reloading the router 4"
sshpass -p imdea ssh imdea@192.168.2.4 /jffs/real_time_aod/./reload.sh

echo "Reloading the router 5"
sshpass -p imdea ssh imdea@192.168.2.5 /jffs/real_time_aod/./reload.sh

echo "Reloading the router 6"
sshpass -p imdea ssh imdea@192.168.2.6 /jffs/real_time_aod/./reload.sh

echo "Reloading the router 3"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/real_time_aod/./reload.sh

echo "Reloading the router 10"
sshpass -p imdea ssh imdea@192.168.2.10 /jffs/real_time_aod/./reload.sh

