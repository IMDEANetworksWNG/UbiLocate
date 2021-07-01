#!/bin/sh

while [ true ]; do
  OUT=$(killall -9 transmit4ever80fastng.sh)
  if [ "$OUT" = "" ]; then
    break
  fi
  usleep 200000
done
while [ true ]; do
  OUT=$(killall -9 t./starttxrx80fastng.sh)
  if [ "$OUT" = "" ]; then
    break
  fi
  usleep 200000
done


while [ true ]; do
  OUT=$(killall -9 nexutilng)
  if [ "$OUT" = "" ]; then
    break
  fi
  usleep 200000
done

while [ true ]; do
  OUT=$(killall -9 tcpdump)
  if [ "$OUT" = "" ]; then
    break
  fi
  usleep 200000
done
