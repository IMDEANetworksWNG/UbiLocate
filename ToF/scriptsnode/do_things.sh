#!/bin/bash
router=$1

if [ "$router" = "" ]; then
  echo "Missing the router"
  exit 1
fi



cd "$(dirname "$0")"


#router=4
echo ${router}

#sshpass -p imdea ssh imdea@192.168.2.${router} rm -rf /jffs/real_time/
#sshpass -p imdea ssh imdea@192.168.2.${router} rm -rf /jffs/real_time_2/
#sshpass -p imdea ssh imdea@192.168.2.${router} mv /jffs/real_time_aod/ /jffs/real_time_aod_2/
sshpass -p imdea ssh imdea@192.168.2.${router} rm -rf /jffs/real_time_aod/
sshpass -p imdea ssh imdea@192.168.2.${router} mkdir /jffs/real_time_aod/ 


sshpass -p imdea scp -p * imdea@192.168.2.${router}:/jffs/real_time_aod/
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/real_time_aod/*.sh
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/real_time_aod/tcpdump
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/real_time_aod/nexutil
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/real_time_aod/makecsiparams
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/real_time_aod/setpackets
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/real_time_aod/nexutilng

