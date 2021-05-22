echo "Setting up the transmitter"
sshpass -p imdea ssh imdea@192.168.2.3 /jffs/LEGACY160/./configcsi.sh 157 80 
sshpass -p imdea ssh imdea@192.168.2.3 /usr/sbin/wl -i eth6 txchain 1
echo "Setting up the receiver"

ASUS="4 5"

for rx in $ASUS ; do
  sshpass -p imdea ssh imdea@192.168.2.${rx} /jffs/csisoftware/./configcsi.sh 1
  sshpass -p imdea ssh imdea@192.168.2.${rx} /jffs/csisoftware/./setdumpparameters.sh 2 0 
done



echo "Setting the chanspec just in case"
sshpass -p imdea ssh imdea@192.168.2.3 /usr/sbin/wl -i eth6 chanspec 157/80 
for rx in $ASUS ; do
  sshpass -p imdea ssh imdea@192.168.2.${rx} /usr/sbin/wl -i eth6 chanspec 157/80
done

