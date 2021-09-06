#!/bin/bash
# number of spatial stream

# ssh logins
us="imdea" # change it
ps="imdea" # change it

# rx and tx numbers
tx="3"
rxs="4"

nss=$1

if [ "$nss" = "" ]; then
  echo "Missing number of spatial streams"
  exit 1
fi

ch=$2

if [ "$ch" = "" ]; then
  echo "Missing the channel"
  exit 1
fi

bw=$3

if [ "$bw" = "" ]; then
  echo "Missing the BW"
  exit 1
fi


case $nss in
1)
  nss_mask=1
  echo $nss_mask 
  ;;
2)
  nss_mask=3
  ;;
3)
  nss_mask=7
  ;;
4)
  nss_mask=15
  ;;
*)
  echo "Invalid spatial streams"
  exit 1
  ;;
esac


echo "Setting up the transmitter"
sshpass -p ${ps} ssh ${us}@192.168.2.${tx} /jffs/LEGACY160/./configcsi.sh 157 80 

#sshpass -p ${ps} ssh ${us}@192.168.2.${tx} /usr/sbin/wl -i eth6 txchain $nss_mask
sshpass -p ${ps} ssh ${us}@192.168.2.${tx} /usr/sbin/wl -i eth6 txcore -k ${nss_mask} -o ${nss_mask} -s  ${nss} -c ${nss_mask}

echo "Setting up the receiver"

for rx in $rxs ; do
  sshpass -p ${ps} ssh ${us}@192.168.2.${rx} /jffs/csisoftware/./configcsi.sh ${nss}
  sshpass -p ${ps} ssh ${us}@192.168.2.${rx} /jffs/csisoftware/./setdumpparameters.sh 2 0 
done


echo "Setting the channel and BW"

echo ${ch}/${bw}

sshpass -p ${ps} ssh ${us}@192.168.2.${tx} /usr/sbin/wl -i eth6 chanspec ${ch}/${bw}
for rx in $rxs ; do
  sshpass -p ${ps} ssh ${us}@192.168.2.${rx} /usr/sbin/wl -i eth6 chanspec ${ch}/${bw}
done

