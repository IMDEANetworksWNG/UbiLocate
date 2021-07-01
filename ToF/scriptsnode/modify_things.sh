#!/bin/bash

cd "$(dirname "$0")"


router=4
sshpass -p imdea scp -r gong_2.sh imdea@192.168.2.${router}:/jffs/real_time_aod/
router=3
sshpass -p imdea scp -r gong_2.sh imdea@192.168.2.${router}:/jffs/real_time_aod/
router=10
sshpass -p imdea scp -r gong_2.sh imdea@192.168.2.${router}:/jffs/real_time_aod/
router=5
sshpass -p imdea scp -r gong_2.sh imdea@192.168.2.${router}:/jffs/real_time_aod/
router=6
sshpass -p imdea scp -r gong_2.sh imdea@192.168.2.${router}:/jffs/real_time_aod/






