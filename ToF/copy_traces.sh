#!/bin/bash
folder=$1
cd "$(dirname "$0")"

mkdir ../../pcap_files_real_2/
mkdir ../../pcap_files_real_2/${folder}
router=4
sshpass -p imdea scp -r imdea@172.16.1.172:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/
router=3
sshpass -p imdea scp -r imdea@192.168.2.3:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/
router=10
sshpass -p imdea scp -r imdea@172.16.1.171:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/
router=5
sshpass -p imdea scp -r imdea@172.16.1.173:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/
router=6
sshpass -p imdea scp -r imdea@172.16.1.174:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/
router=7
sshpass -p imdea scp -r imdea@172.16.1.175:/tmp/trace${router}.pcap ../../pcap_files_real_2/${folder}/

