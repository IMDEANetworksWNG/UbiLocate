#!/bin/sh

DELAY=$1
if [ "$DELAY" = "" ]; then
  echo "Missing delay, set default to 100ms"
  DELAY=100000
fi
./nexutil -I eth6 -s 505 -l 574 -f packet.dat -n 1000000 -t $DELAY

