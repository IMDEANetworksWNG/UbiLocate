#!/bin/sh

cd "$(dirname "$0")"

DELAY=$1
if [ "$DELAY" = "" ]; then
  echo "Missing delay, set default to 100ms"
  DELAY=100000
fi
./nexutilng -I eth6 -s 529 -l 574 -f packetnode1x1BP.dat -n 1000000 -t $DELAY

