#!/bin/bash

FILE=$1

if [ "$FILE" = "" ]; then
  echo "Missing filename"
  exit 1
fi

NAMEnoEXT=$(echo $FILE | awk -F".pcap" '{ print $1}')

tcpdump -n -r $FILE -w ${NAMEnoEXT}_20MHZ.pcap  \(udp and ether[0x33] == 0x9b\) or \(not udp and ether[0x9f] == 0x9b\)
tcpdump -n -r $FILE -w ${NAMEnoEXT}_80MHZ.pcap  \(udp and ether[0x33] == 0x9c\) or \(not udp and ether[0x9f] == 0x9c\)

