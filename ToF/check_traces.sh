#!/bin/bash

cd "$(dirname "$0")"

  echo "Cheking traces"
  #router=4
  router=172
  sendcmd -s 172.16.1.${router} -p 30000 -c "ls -ahl /tmp/*.pcap"
  #router=3
  router=3
  sendcmd -s 192.168.2.${router} -p 30000 -c "ls -ahl /tmp/*.pcap"
  #router=10
  router=171
  sendcmd -s 172.16.1.${router} -p 30000 -c "ls -ahl /tmp/*.pcap"
  #router=5
  router=173
  sendcmd -s 172.16.1.${router} -p 30000 -c "ls -ahl /tmp/*.pcap"
  #router=6
  router=174
  sendcmd -s 172.16.1.${router} -p 30000 -c "ls -ahl /tmp/*.pcap"
  #router=7
  router=175
  sendcmd -s 172.16.1.${router} -p 30000 -c "ls -ahl /tmp/*.pcap"
  sleep 1







