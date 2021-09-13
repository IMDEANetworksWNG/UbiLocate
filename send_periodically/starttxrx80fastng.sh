#!/bin/sh


cd "$(dirname "$0")"
echo $PATH
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/home/imdea:/mmc/sbin:/mmc/bin:/mmc/usr/sbin:/mmc/usr/bin:/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin
echo $PATH
BW=80

# start transmitting every 4ms
./transmit4ever80fastng.sh 4000 >/dev/null 2>&1 &

# capture pcap
NODEID=$(ifconfig br0 | grep inet | awk '{ print $2 }' | awk -F"." '{ print $4 }')
./tcpdump -i eth6 -c 1000 -nn -w /tmp/trace${NODEID}.pcap
echo "received 1000 frames"

# transmit for another 2 seconds
echo "transmitting for another 2 seconds"
sleep 2


while [ true ]; do
  OUT=$(killall -9 transmit4ever80fastng.sh)
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

