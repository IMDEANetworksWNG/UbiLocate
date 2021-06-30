#!/bin/sh

FILE=$1
if [ "$FILE" = "" ]; then
  echo "Missing filename"
  exit 1
fi

/jffs/asusscripts/./tcpdump -i eth6 -nn -s 0 -w /tmp/$FILE port 5500 
