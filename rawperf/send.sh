#!/bin/sh

cd "$(dirname "$0")"

packets=$1

if [ "$packets" = "" ]; then
  echo "Missing the packets"
  exit 1
fi


./rawperf -i eth6 -n ${packets} -f packetnode1x1BP.dat -t 4000 -q 0 
