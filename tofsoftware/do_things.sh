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
#sshpass -p imdea ssh imdea@192.168.2.${router} mv /jffs/tofsoftware/ /jffs/real_time_aod_2/
sshpass -p imdea ssh imdea@192.168.2.${router} rm -rf /jffs/tofsoftware/
sshpass -p imdea ssh imdea@192.168.2.${router} mkdir /jffs/tofsoftware/ 


sshpass -p imdea scp -p * imdea@192.168.2.${router}:/jffs/tofsoftware/
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/tofsoftware/*.sh
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/tofsoftware/tcpdump
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/tofsoftware/nexutil
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/tofsoftware/makecsiparams
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/tofsoftware/setpackets
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/tofsoftware/nexutilng

