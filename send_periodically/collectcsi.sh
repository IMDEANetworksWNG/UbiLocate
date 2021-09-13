#!/bin/sh

cd "$(dirname "$0")"

FILE=$1
if [ "$FILE" = "" ]; then
  echo "Missing filename"
  exit 1
fi

./tcpdump -i eth6 -nn -s 0 -w /tmp/$FILE port 5500 
