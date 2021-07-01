#!/bin/sh

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

CONFIG=$(./makecsiparams -e 1 -m ff:ff:00:12:34:56 -c 0xe29b -C 0x1 -N 0x1 -b 0x88)
LEN=34
../nexutil -I eth6 -s500 -b -l${LEN} -v${CONFIG} 

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

# do not pace frames (don't send too fast!)
wl -i eth6 shmem 0x177e 0x0

# start transmitting
./transmit4ever80slowmixedid.sh >/dev/null 2>&1 &

# capture pcap
NODEID=$(ifconfig br0 | grep inet | awk '{ print $2 }' | awk -F"." '{ print $4 }')
./tcpdump -i eth6 -nn -c 1000 -w /tmp/trace${NODEID}.pcap
echo "received 1000 frames"

# transmit for another 5 seconds
echo "transmitting for another 5 seconds"
sleep 5


while [ true ]; do
  OUT=$(killall -9 transmit4ever80slowmixedid.sh)
  if [ "$OUT" = "" ]; then
    break
  fi
  usleep 200000
done
