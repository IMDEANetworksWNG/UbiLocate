#!/bin/bash
SS=$1

cd "$(dirname "$0")"

if [ "$SS" = "" ]; then
  echo "Missing the number of spatial streams"
  exit 1
fi

SS_hx=0

case $SS in
1)
  SS_hx=1
  ;;
2)
  SS_hx=3
  ;;
3)
  SS_hx=7
  ;;
4)
  SS_hx=f
  ;;
*)
  echo "Invalid spatial stream"
  exit 1
  ;;
esac

/usr/sbin/wl -i eth6 up
/usr/sbin/wl -i eth6 radio on
/usr/sbin/wl -i eth6 country UG
/usr/sbin/wl -i eth6 chanspec 40/160
/usr/sbin/wl -i eth6 monitor 1
/sbin/ifconfig eth6 up


#change -N to have more spatial streams
echo ${SS_hx}
CONFIG=$(./makecsiparams -e 1 -m 00:12:34:56:78:9b -c 0xe27a -C 0xf -N 0x${SS_hx} -d 0x50 -b 0x88)
LEN=34
./nexutil -I eth6 -s500 -b -l${LEN} -v${CONFIG} 


./setdumpparameters.sh 2 0

/usr/sbin/wl -i eth6 chanspec 157/80
