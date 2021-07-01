#!/bin/bash
router=$1
folder=$2

if [ "$router" = "" ]; then
  echo "Missing the RX"
  exit 1
fi


if [ "$folder" = "" ]; then
  echo "Missing the folder"
  exit 1
fi


cd "$(dirname "$0")"

mkdir ../../pcap_files_real_2/
mkdir ../../pcap_files_real_2/${folder}
mkdir ../../pcap_files_real_2/${folder}/${router}

if [ "$router" = "4" ];then
  routerimdea=172
fi
if [ "$router" = "10" ];then
  routerimdea=171
fi
if [ "$router" = "5" ];then
  routerimdea=173
fi
if [ "$router" = "6" ];then
  routerimdea=174
fi
if [ "$router" = "7" ];then
  routerimdea=175
fi

#router=4
sshpass -p imdea scp -r imdea@172.16.1.${routerimdea}:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/${router}/
sshpass -p imdea scp -r imdea@192.168.2.3:/tmp/trace3.pcap ../../pcap_files_real_2/${folder}/${router}/

