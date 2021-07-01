#!/bin/sh

BW=20

# equivalent to configcsiblablabla.sh
/usr/sbin/wl -i eth5 up
/usr/sbin/wl -i eth5 radio on
/usr/sbin/wl -i eth5 country UG
/usr/sbin/wl -i eth5 chanspec 6/20
/usr/sbin/wl -i eth5 monitor 1
/sbin/ifconfig eth5 up

CONFIG=$(./makecsiparams -e 1 -m 00:12:34:56:78:9b -c 0x1006 -C 0x1 -N 0x1 -b 0x88)
LEN=34
../nexutil -I eth5 -s500 -b -l${LEN} -v${CONFIG} 

# equivalent to ./setdumpparameters 2 0
wl -i eth5 shmem 0x172a 2
wl -i eth5 shmem 0x172c 0

# set txcore
wl -i eth5 txcore -s 1 -c 1 -o 1 -k 1

# equivalent to setrxcore.sh
./nexutil -Ieth5 -s528 -i -v1 -l 2

# now reset channel
# wl -i eth5 chanspec 6/$BW

# equivalent to restarthfc.sh
wl -i eth5 shmem 0x1776 0x9000

# start transmitting
./transmit4ever2G.sh >/dev/null 2>&1 &

# capture pcap
NODEID=$(ifconfig br0 | grep inet | awk '{ print $2 }' | awk -F"." '{ print $4 }')
./tcpdump -i eth5 -nn -c 1000 -w /tmp/trace${NODEID}.pcap
echo "received 1000 frames"

# transmit for another 5 seconds
echo "transmitting for another 5 seconds"
sleep 5


while [ true ]; do
  OUT=$(killall -9 transmit4ever2G.sh)
  if [ "$OUT" = "" ]; then
    break
  fi
  usleep 200000
done
