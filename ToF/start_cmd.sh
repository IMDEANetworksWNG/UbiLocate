#!/bin/bash
echo "rx 10"
sshpass -p imdea ssh imdea@172.16.1.171 /jffs/ToF_2/./start_cmd.sh
sshpass -p imdea ssh imdea@172.16.1.171 /usr/sbin/iptables -F 
echo "rx 3"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/ToF_2/./start_cmd.sh 
sshpass -p imdea ssh imdea@192.168.2.3 /usr/sbin/iptables -F 
echo "rx 4"
sshpass -p imdea ssh imdea@172.16.1.172 /jffs/ToF_2/./start_cmd.sh 
sshpass -p imdea ssh imdea@172.16.1.172 /usr/sbin/iptables -F 
echo "rx 5"
sshpass -p imdea ssh imdea@172.16.1.173 /jffs/ToF_2/./start_cmd.sh 
sshpass -p imdea ssh imdea@172.16.1.173 /usr/sbin/iptables -F
echo "rx 6"
sshpass -p imdea ssh imdea@172.16.1.174 /jffs/ToF_2/./start_cmd.sh 
sshpass -p imdea ssh imdea@172.16.1.174 /usr/sbin/iptables -F
echo "rx 7"
sshpass -p imdea ssh imdea@172.16.1.175 /jffs/ToF_2/./start_cmd.sh 
sshpass -p imdea ssh imdea@172.16.1.175 /usr/sbin/iptables -F
