#!/bin/bash

if [ "$1" != "" ]; then
  REPEAT=$1
else
  REPEAT=1
fi

while [ "$REPEAT" != "0" ]; do
./nexutil -I eth6 -s 505 -l 574 -f packet.dat -n 1 -t 0
REPEAT=$((REPEAT-1))
done
