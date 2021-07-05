# This GitHub project contains all the files needed to run UbiLocate.


UbiLocate is a WiFi indoor localization system that copes well with 
common AP deployment densities and works ubiquitously, i.e., 
without excessive degradation under NLOS. It is completely
implemented on off-the-shelf 801.11ac router. You can download the paper
from [here](https://eprints.networks.imdea.org/2318/1/main.pdf)

UbiLocate was presented at MobiSys 2021 and we kindly invite you
to take a look at the full presentation [on TouTube](https://www.youtube.com/watch?v=ULfg9MV4ymQ)


### You can find all the details about running UbiLocate below

## Table of content

- [Getting started](#gettingstarted)
- [Set up the router](#set-up-the-router).
- [Extracting CSI](#extracting-csi)
- [Getting CSI by MATLAB](#getting-csi-by-matlab)
- [Calibrating the router](#calibrating-the-router)
- [Extracting the path parameters by MATLAB](#extracting-the-path-parameters-by-matlab)
- [Extracting ToF](#extracting-tof)

<!----- [Files](#files)--->

<!---- [Enabling NTP on a linux server](#enabling-ntp-on-a-linux-server)--->


# Getting started

UbiLocate uses the ASUS RT-AC86U. It can support up to 4x4 MIMO with 80MHz of BW. Following the instruction below, you will 
be able to configure and extract the CSI for every configuration. 

The implementation of UbiLocate has two main parts:

1) **CSI extraction**. It extracts the CSI of IEEE 802.11ac frames. This part is mainly designed for estimating the angle of arrival (AoA) and angle of departure (AoD) plus the relative time delay between paths. We will explain how to calibrate the router for AoA/AoD too at [Calibrating the router](#calibrating-the-router). Once, the router is calibrated, the path parameters can be extracted (AoA/AoD/Path length), look at [Extracting the path parameters by MATLAB](#extracting-the-path-parameters-by-matlab)

2) **ToF extraction**. It extracts the Time of Flight (ToF) from two or more devices. It gets the timestamps when the packets are received and sent so that the ToF can be computed.

The image below shows the router. We remove the frontal plastic panel to access to the internal antenna so that we can handle the 4 RF-chains.
Nota that, the logical index of the CSI extractor tool correspond to the physical port as it is displayed in the image. As an example, the CSI of the first chain correspond to the rightmost physical port (1).

<img src="https://github.com/IMDEANetworksWNG/UbiLocate/blob/main/Router_Array_Final_Index.jpg" width="600" height="300">


<!-- 
## Files


The GitHub project contains the following subfolders:
* csisoftware: It contains the files to configure the RX routers for CSI
* LEGACY160: It contains the files to configure the TX router for CSI
* hardware_scripts: It contains the bash files to automatize
the extraction of the CSI data. It takes the CSI from the router
and save it in a pcap files
* trace: It contains the pcap files
* matlab_Scripts: It contains the scripts to extract the CSI
data from pcap files to MATLAB files and also calibrate the CSI
* mat_files: It contains the mat files, CSI data
* tofsoftware: It contains the files to configure the router for ToF
-->



## Set up the router

First, you have to configure the router by the ASUS webpage.

* Give an IP in the range of 192.168.2.X where X is the IP assigned
by each router.
* Enable SSH
* Put the router in AP mode 
* Update the firmware. The firmware is
the name is: FW_RT-AC86U_300438215098.w. To do so, follow the instruction in the [link](https://www.asus.com/support/FAQ/1008000/#a2), follow Method 2: Update Manually


Once these steps are done:
* Copy the csisoftware to the RX router inside the /jffs/
 folder
* Copy the LEGACY160 to the TX router inside the /jffs/ folder
* Copy the tofsoftware to every router inside the /jffs/ folder

## Extracting CSI

To extract CSI, you have to use the files in hadware_scripts. 
These scripts automitize the extraction based on the scripts 
inside csisoftware and LEGACY160.

To do that: run the following commands:

1) Load the dhd.ko module to extract CSi
```
bash reload.sh 
```
2) Configure the TX and RX router. Note that nss means the number of spatial stream. Use 1 (1x4 MIMO) or 4 (4x4 MIMO). Channel means the 11ac channel and bw is the BW im MHz. For more information please take a look at [here](https://en.wikipedia.org/wiki/List_of_WLAN_channels#5_GHz_(802.11a/h/j/n/ac/ax)). Recommended channel and BW 157 and 80.
```
bash config.sh nss ch bw
```
 
These two scripts must be executed one time. Once you do a power cycle
of the router you have to run them another time.

To send packets and extract CSI, run this command:
```
bash send_collect.sh name ss packets bw
```
where name is the name of the folder where you want to save the traces,
ss means number of spatial streams (recommended values 1 or 4), packets
means the number of packets to send and bw is the bandwith. 

NOTE1: Every bash file is configured with the login and pass as imdea.
Please change it. The variables are at the beggining of every file us and pw:
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

If extracting CSI from more than one router is needed, just simple add more numbers at the end. Example rxs="4 5"

## Getting CSI by MATLAB


Run the follwoing mat_files (change the BW if it is not 80): 
1) 1 spatial stream:
```
matlab_scripts/Extract_Data/Extract_CSI_1.m
```

2) 4 spatial stream:
```
matlab_scripts/Extract_Data/Extract_CSI_4.m
```

The csi data will be in the variable csi_data, it has a size of (Number of Packets) X (Number of Subcarriers) X (RX chains) X (Spatial steams). For example, if you have configured the routers to extract 4 RX chains with 4 spatial streams and 80MHZ. The size is (Number of Packets) X (256) X (4) X (4)


## Calibrating the router

In order to correctly estimate AoA and AoD, the CSI data has to be calibrated. To do so, collect a reference CSI. This reference CSI has to be taken by cables with the exact TX and RX devices that are going to use for extracting AoA and AoD. To do so, connect every TX port to each input of a 4-way combiner, the output of the combiner to the input of the 4-way splitter and every the output of the splitter to every RX port. With this configuration, you can connect all the TX port with all the RX port. Maybe it is needed to separate this into subgroups of TX and RX ports. If one spatial stream is used, just connect the TX port to the input of the splitter.

Once, the reference CSI is taken. Disconnect all the cables to the splitter/combiner, connect to the antennas and collect the measurements that will use for estimating AoA and AoD later. If the setup is modified, the calibration won't work. In addition, the calibration only works while the routers are on, a power cycle will change the physical configuration and the calibration will be lost.

To calibrate the data, there is an example. Just execute in MATLAB UbiLocate/matlab_scripts/calibrate_data/Calibrate_CSI_Data.m.

## Extracting the path parameters by MATLAB

We make public the algorithm for estimating the path parameters, Decompose. This algorithm corresponds to the one explained in Section 2.2 Angle estimation. There are two example in UbiLocate/matlab_scripts/Extract_Path_Parameters/. 

1) Handle_Decompose_2D: It decomposes the channel in 5 paths and extracts the parameters (AoA and path lenght)
2) Handle_Decompose_3D: It decomposes the channel in 5 paths and extracts the parameters (AoA, AoD and path lenght)


## Extracting ToF

UNDER CONSTRUCTION. Stay tune! I will update it in a couple of days

First, you have to compile the .c files in cmdserver, create the executables
and copy them in your bin folder. To do everything, run these commands:
```
cd cmdserver-0.0.4/
make clean
make
```

If no errors appear, do:
```
chmod +x cmdserver receivefile sendcmd sendfile
sudo cp cmdserver receivefile sendcmd sendfile /usr/local/bin/
```

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
