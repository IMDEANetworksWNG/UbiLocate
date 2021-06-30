**This GitHub project contains all the files needed to run UbiLocate.**


UbiLocate is WiFi indoor localization system that copes well with 
common AP deployment densities and works ubiquitously, i.e., 
without excessive degradation under NLOS. It is completely
implemented on off-the-shelf 801.11ac router. You can download the paper
from [here](https://eprints.networks.imdea.org/2318/1/main.pdf)

UbiLocate was presented at MobiSys 2021 and we kindly invite you
to take a look at the full presentation [on TouTube](https://www.youtube.com/watch?v=ULfg9MV4ymQ)


### You can find all the details about running UbiLocate below

## Table of content

- [Files](#files)
- [Set up the router](#set-up-the-router).
- [Extracting CSI](#extracting-csi)
- [Getting CSI by MATLAB](#getting-csi-by-matlab)
<!---- [Enabling NTP on a linux server](#enabling-ntp-on-a-linux-server)--->



## Files

The GitHUb project contains the following subfolders:
* csisoftware: It contais the files to configure the RX routers
* LEGACY160: It contains the files to configure the TX router
* hardware_scripts: It contains the bas files to automatize
the extraction of the CSI data. It takes the CSI from the router
and save it in a pcap files
* trace: It contains the pcap files
* matlab_Scripts: It constains the scripts to extract the CSI
data from pcap files to MATLAB files and also calibrate the CSI
* mat_files: It contains the mat files, CSI data


## Set up the router

First, you have to configure the router by the ASUS webpage.

* Give an IP in the range of 192.168.2.X where X is the IP assigned
by each router.
* Enable SSH
* Put the router in AP mode 
* Update the firmware. Update the firmware, you have it in the folder
the name is: FW_RT-AC86U_300438215098.w


Once these steps are done:
* Copy the csisoftware to the RX router inside the /jffs/
 folder
* Copyt the LEGACY160 to the TX router inside the /jffs/ folder

## Extracting CSI

To extract CSI, you have to use the files in hadware_scripts. 
These scripts automitize the extraction based on the scripts 
inside csisoftware and LEGACY160.

To do that: run the following commands:

1) Load the dhd.ko module to extract CSi
```
bash reload.sh 
```
2) Configure the TX and RX router. Note that nss means the number of spatial stream. Use 1 or 4
```
bash config.sh nss
```
 
These two scripts must be run one time, once you do a power cycle
of the router you have to run them another time.

To send packets and extract CSI, run this command:
```
bash send_collect.sh name ss packets
```
where name is the name of the folder where you want to save the traces,
ss means number of spatial streams (recommended values 1 or 4) and packets
means the number of packets to send

NOTE1: Every bash file is configured with the login and pass from as imdea.
Please change it. The variable are at the beggining of every file us and pw:
```
# ssh logins
us="imdea" # change it
ps="imdea" # change it
```

NOTE2: This scripts assume that the TX is 192.168.2.3 and 1 RX as 192.168.2.4.
Change the numbers:
```
# rx and tx numbers
tx="3"
rxs="4"
```

If you want to extract CSI from more than one router. Simple add more numbers at the end. Example rxs="4 5"


## Getting CSI by MATLAB


Run the follwoing mat_files.
1) 1 spatial stream:
```
matlab_scripts/Extract_Data/Extract_CSI_1.m
```

2) 4 spatial stream:
```
matlab_scripts/Extract_Data/Extract_CSI_4.m
```

The csi data will be in the variable csi_data. Save it!
<!-- 
-----------------------------------------------------------------
How to calibrate the data
-----------------------------------------------------------------
To calibrate the data you have to connect the the rightmost 
antenna of the TX to a spliiter and every output of the splitter
to every port of the RX router. If one output is not use, please
connect a 50 ohms resistor.

Once this setup is ready, please run bash send_collect.sh calibration
to extrac the csi data that it will be use to calibrate over the 
air data.

Once, this is done and you want to extract CSI from over the air
packets, connect the cables to the antennas.

PLEASE, note that the logical indexes of the port of the router 
do not correspond to the physical ones, please see ~/Router_Array_Final_Index.jpg
I will use the same one for the antenna array.


## Enabling NTP on a linux server

In order to save the CSI data, you have to install NTP in a linux
server, this server must be connected to all routers, it must
be in the same network.

To do that, run the following commands:
* sudo apt-get install ntp

Also run:
gcc -o hardware_scripts/csicollector hardware_scripts/csicollector.c -lpcap

Then you need to configure each asus in order to use the linux computer
as ntp synch server. To do this, open the web interface, go to
“Administration”, “System”, there is a box with “NTP Server”, 
fill it with the IP address of the linux computer.

Start NTP server, run:

sudo /etc/init.d/ntp start

The server have to be running while the capturing CSI data


-->
