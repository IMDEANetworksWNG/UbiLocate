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
#sshpass -p imdea ssh imdea@192.168.2.${router} mv /jffs/send_periodically/ /jffs/real_time_aod_2/
sshpass -p imdea ssh imdea@192.168.2.${router} rm -rf /jffs/send_periodically/
sshpass -p imdea ssh imdea@192.168.2.${router} mkdir /jffs/send_periodically/ 


sshpass -p imdea scp -p * imdea@192.168.2.${router}:/jffs/send_periodically/
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/*.sh
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/tcpdump
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/nexutil
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/makecsiparams
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/setpackets
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/nexutilng
sshpass -p imdea ssh imdea@192.168.2.${router} chmod +x /jffs/send_periodically/rawperf
