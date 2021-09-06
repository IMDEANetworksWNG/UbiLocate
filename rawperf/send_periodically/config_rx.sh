#!/bin/sh

nss=$1

if [ "$nss" = "" ]; then
  echo "Missing number of spatial streams"
  exit 1
fi


case $nss in
1)
  nss_mask=1
  echo $nss_mask 
  ;;
4)
  nss_mask=f
  ;;
*)
  echo "Invalid spatial streams"
  exit 1
  ;;
esac


cd "$(dirname "$0")"
echo $PATH
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/home/imdea:/mmc/sbin:/mmc/bin:/mmc/usr/sbin:/mmc/usr/bin:/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin
echo $PATH
BW=80

# equivalent to configcsiblablabla.sh
/usr/sbin/wl -i eth6 up
/usr/sbin/wl -i eth6 radio on
/usr/sbin/wl -i eth6 country UG
/usr/sbin/wl -i eth6 chanspec 157/80
/usr/sbin/wl -i eth6 monitor 1
/sbin/ifconfig eth6 up

# generate packet
NODEID=$(ifconfig br0 | grep inet | awk '{ print $2 }' | awk -F"." '{ print $4 }')
./setpackets $NODEID
dd if=/dev/zero bs=4 count=1 of=/tmp/4zeroes
cat /tmp/4zeroes packetnode1x1.dat > packetnode1x1BP.dat

CONFIG=$(./makecsiparams -e 1 -m ff:ff:00:12:34:56 -c 0xe29b -C 0xf -N 0x${nss_mask} -b 0x88)
LEN=34
./nexutil -I eth6 -s500 -b -l${LEN} -v${CONFIG} 

# equivalent to ./setdumpparameters 2 0
wl -i eth6 shmem 0x172a 2
wl -i eth6 shmem 0x172c 0

# set txcore
wl -i eth6 txcore -s 1 -c 1 -o 1 -k 1

# equivalent to setrxcore.sh
./nexutil -Ieth6 -s528 -i -v15 -l 2

# now reset channel
# wl -i eth6 chanspec 157/$BW

# equivalent to restarthfc.sh
wl -i eth6 shmem 0x1776 0x9000

# pace frames every 4ms
wl -i eth6 shmem 0x177e 0xf000

