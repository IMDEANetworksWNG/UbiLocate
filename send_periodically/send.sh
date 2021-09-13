#!/bin/sh

cd "$(dirname "$0")"

packets=$1

if [ "$packets" = "" ]; then
  echo "Missing the packets"
  exit 1
fi

nss=$2

if [ "$nss" = "" ]; then
  echo "Missing number of spatial streams"
  exit 1
fi


case $nss in
1)
  nss_mask=0
  ;;
4)
  nss_mask=1
  ;;
*)
  echo "Invalid spatial streams"
  exit 1
  ;;
esac


./rawperf -i eth6 -n ${packets} -f packetnode1x1BP.dat -t 8000 -q ${nss_mask} 
