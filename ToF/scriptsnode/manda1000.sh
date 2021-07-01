#!/bin/sh

I=0
while [ true ]; do
  ./nexutil -I eth6 -s 505 -l 576 -f packet.dat -n 100 -t 0
  usleep 400000  
  I=$((I+1))
  if [ "$I" = 10 ]; then
    break
  fi
done
