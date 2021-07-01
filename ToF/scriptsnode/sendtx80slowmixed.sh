#!/bin/bash

if [ "$1" != "" ]; then
  REPEAT=$1
else
  REPEAT=1
fi

CYCLE=32

while [ "$REPEAT" -gt "0" ]; do
  TX1S=$CYCLE
  while [ "$TX1S" != "0" ]; do
    ./nexutil -I eth6 -s 505 -l 574 -f packet.dat -n 1 -t 0
    TX1S=$((TX1S-1))
  done
  ./nexutil -I eth6 -s 505 -l 574 -f packet4x4.dat -n 1 -t 0
  REPEAT=$((REPEAT-CYCLE))
  usleep 10000
done
