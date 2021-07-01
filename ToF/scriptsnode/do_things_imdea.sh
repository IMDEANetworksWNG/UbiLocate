#!/bin/bash
router=$1

if [ "$router" = "" ]; then
  echo "Missing the router"
  exit 1
fi

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

router=$routerimdea

cd "$(dirname "$0")"


#router=4
echo ${router}

#sshpass -p imdea ssh imdea@172.16.1.${router} rm -rf /jffs/real_time/
#sshpass -p imdea ssh imdea@172.16.1.${router} rm -rf /jffs/real_time_2/
#sshpass -p imdea ssh imdea@172.16.1.${router} mv /jffs/real_time_aod/ /jffs/real_time_aod_2/
sshpass -p imdea ssh imdea@172.16.1.${router} rm -rf /jffs/real_time_aod/
sshpass -p imdea ssh imdea@172.16.1.${router} mkdir /jffs/real_time_aod/ 


sshpass -p imdea scp -p * imdea@172.16.1.${router}:/jffs/real_time_aod/
sshpass -p imdea ssh imdea@172.16.1.${router} chmod +x /jffs/real_time_aod/*.sh
sshpass -p imdea ssh imdea@172.16.1.${router} chmod +x /jffs/real_time_aod/tcpdump
sshpass -p imdea ssh imdea@172.16.1.${router} chmod +x /jffs/real_time_aod/nexutil
sshpass -p imdea ssh imdea@172.16.1.${router} chmod +x /jffs/real_time_aod/makecsiparams
sshpass -p imdea ssh imdea@172.16.1.${router} chmod +x /jffs/real_time_aod/setpackets
sshpass -p imdea ssh imdea@172.16.1.${router} chmod +x /jffs/real_time_aod/nexutilng

