#!/bin/bash
echo "Config the router 4"
sshpass -p imdea ssh imdea@172.16.1.172 /jffs/real_time_aod/./config.sh

echo "Config the router 5"
sshpass -p imdea ssh imdea@172.16.1.173 /jffs/real_time_aod/./config.sh

echo "Config the router 6"
sshpass -p imdea ssh imdea@172.16.1.174 /jffs/real_time_aod/./config.sh

echo "Config the router 7"
sshpass -p imdea ssh imdea@172.16.1.175 /jffs/real_time_aod/./config.sh

echo "Config the router 3"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/real_time_aod/./config.sh

echo "Config the router 10"
sshpass -p imdea ssh imdea@172.16.1.171 /jffs/real_time_aod/./config.sh

