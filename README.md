# This GitHub project contains all the needed files to run UbiLocate.


UbiLocate is a WiFi indoor localization system that copes well with 
common AP deployment densities and works ubiquitously, i.e., 
without excessive degradation under NLOS. It is completely
implemented on off-the-shelf 802.11ac router. You can download the paper
from [here](https://eprints.networks.imdea.org/2318/1/main.pdf)

UbiLocate was presented at MobiSys 2021. If you find UbiLocate useful, we kindly ask you to cite the paper:
```
@inproceedings{UbiLocate,
author = {Pizarro, Alejandro Blanco and Beltr\'{a}n, Joan Palacios and Cominelli, Marco and Gringoli, Francesco and Widmer, Joerg},
title = {Accurate Ubiquitous Localization with Off-the-Shelf IEEE 802.11ac Devices},
year = {2021},
isbn = {9781450384438},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3458864.3468850},
doi = {10.1145/3458864.3468850},
booktitle = {Proceedings of the 19th Annual International Conference on Mobile Systems, Applications, and Services},
pages = {241–254},
numpages = {14},
keywords = {CSI, wireless networks, indoor localization, AoA, ToF, 802.11ac},
location = {Virtual Event, Wisconsin},
series = {MobiSys '21}
}
```


### You can find all the details about running UbiLocate below

## Table of content

- [Getting started](#gettingstarted)
- [Set up the router](#set-up-the-router).
- [Extracting CSI](#extracting-csi)
- [Extracting CSI faster](#extracting-csi-faster)
- [Calibrating the router](#calibrating-the-router)
- [Extracting the path parameters by MATLAB](#extracting-the-path-parameters-by-matlab)
- [Extracting ToF](#extracting-tof)
- [Limitations](#limitations)
- [FAQs](#faqs)

<!----- [Files](#files)--->

<!---- [Enabling NTP on a linux server](#enabling-ntp-on-a-linux-server)--->


# Getting started

UbiLocate uses the ASUS RT-AC86U. It can support up to 4x4 MIMO with 80MHz of BW. Following the instruction below, you will 
be able to configure and extract the CSI for every configuration. 

The implementation of UbiLocate has two main parts:

1) **CSI extraction**. It extracts the CSI of IEEE 802.11ac frames. This part is mainly designed for estimating the angle of arrival (AoA) and angle of departure (AoD) plus the relative time delay between paths. We will explain how to calibrate the router for AoA/AoD too at [Calibrating the router](#calibrating-the-router). Once, the router is calibrated, the path parameters can be extracted (AoA/AoD/Path length), look at [Extracting the path parameters by MATLAB](#extracting-the-path-parameters-by-matlab)

2) **ToF extraction**. It extracts the Time of Flight (ToF) from two or more devices. It gets the timestamps when the packets are received and sent so that the ToF can be computed, look at [Extracting ToF](#extracting-tof). This implemetation also extracts a full MIMO CSi matrix every 32 packets, so that AoA and AoD can be also extracted.

The image below shows the router. We remove the frontal plastic panel to access to the internal antenna so that we can handle the 4 RF-chains.
Nota that, the logical index of the CSI extractor tool correspond to the physical port as it is displayed in the image. As an example, the CSI of the first chain correspond to the rightmost physical port (1). **When connecting the physical ports to the antennas of the array, connect them in order. The port 1 to the rightmost antenna, the port 2 to the second rightmost antenna an so on.**

<img src="https://github.com/IMDEANetworksWNG/UbiLocate/blob/main/Router_Array_Final_Index.jpg" width="600" height="300">


## Set up the router

First, you have to configure the router by the ASUS webpage.

* Give an IP in the range of 192.168.2.X where X is the IP assigned
by each router.
* Enable SSH
* Put the router in AP mode 
* Update the firmware. The firmware is: FW_RT-AC86U_300438215098.w. To do so, follow the instruction in the [link](https://www.asus.com/support/FAQ/1008000/#a2), follow Method 2: Update Manually


Once these steps are done:
* Copy the csisoftware to the RX routers inside the /jffs/
 folder
* Copy the LEGACY160 to the TX router inside the /jffs/ folder
* Copy the tofsoftware to every router inside the /jffs/ folder
* Copy the send_periodically to every router inside the /jffs/ folder
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

NOTE2: These scripts assume that the TX is 192.168.2.3 and 1 RX as 192.168.2.4.
Change the numbers:
```
# rx and tx numbers
tx="3"
rxs="4"
```

If extracting CSI from more than one router is needed, just simple add more numbers at the end. Example rxs="4 5"

Once this is done. You can get the CSI by MATLAB as follows:

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

## Extracting CSI faster
This UbiLocate version sends packet faster than the previous one. **To do so, you need to use the files in hadware_scripts_periodically** which will automatize the CSI extraction based on the files inside send_periodically. The folder send_periodically must be on the router. 

The sending packet rate can be configured. The defaults setting is to send packets every 8ms. To tune the packet rate, you need to modify two files.

1) harware_scripts_periodically/config.sh
```
# pace frames every 8ms
wl -i eth6 shmem 0x177e 0xe000
```
0xe000 means 8ms. If the one's complement is applied, the results is: 0x1fff = 8191 which correspond closely to 8ms. 4ms means 0xf000 and 2ms means 0xf800. 

2) harware_scripts_periodically/send.sh
```
./rawperf -i eth6 -n ${packets} -f packetnode1x1BP.dat -t 8000 -q ${nss_mask}
```
where 8000 means 8ms, change it accordignly.

**To config and sending, follow the steps below:**

Go to the folder harware_scripts_periodically, afterwards: 

1) Load the dhd.ko module to extract CSi
```
bash reload.sh 
```
2) Configure the TX and RX router. Note that nss means the number of spatial stream. Use 1 (1x4 MIMO) or 4 (4x4 MIMO).
```
bash config.sh nss
```
 
These two scripts must be executed one time. Once you do a power cycle of the router you have to run them another time.

To send packets and extract CSI, run this command:
```
bash send_collect.sh name packets ss
```
where name is the name of the folder where you want to save the traces,
ss means number of spatial streams, possible values 1 (1x4 MIMO) or 4 (4x4 MIMO), packets
means the number of packets to send. **It sends 80MHz only**

NOTE1: Every bash file is configured with the login and pass as imdea.
Please change it. The variables are at the beggining of every file us and pw:
```
# ssh logins
us="imdea" # change it
ps="imdea" # change it
```

NOTE2: These scripts assume that the TX is 192.168.2.3 and 1 RX as 192.168.2.4.
Change the numbers:
```
# rx and tx numbers
tx="3"
rxs="4"
```

If extracting CSI from more than one router is needed, just simple add more numbers at the end. Example rxs="4 5"

Once this is done. You can get the CSI by MATLAB as follows:
```
matlab_scripts/Extract_Data_rawperf/Save_data.m
```

The csi data will be in the variable csi_data, it has a size of (Number of Packets) X (Number of Subcarriers) X (RX chains) X (Spatial steams). For example, if you have configured the routers to extract 4 RX chains with 4 spatial streams and 80MHz. The size is (Number of Packets) X (256) X (4) X (4). In addition, you may want to save the toa_packets variable which contains the time of arrival of every packet. 


## Calibrating the router

In order to correctly estimate AoA and AoD, the CSI data has to be calibrated. To do so, collect a reference CSI. This reference CSI has to be taken by cables with the exact TX and RX devices that are going to use for extracting AoA and AoD. To do so, connect every TX port to each input of a 4-way combiner, the output of the combiner to the input of the 4-way splitter and every the output of the splitter to every RX port. With this configuration, you can connect all the TX port with all the RX port. Maybe it is needed to separate this into subgroups of TX and RX ports. If one spatial stream is used, just connect the TX port to the input of the splitter.

Once, the reference CSI is taken. Disconnect all the cables to the splitter/combiner, connect to the antennas and collect the measurements that will use for estimating AoA and AoD later. If the setup is modified, the calibration won't work. In addition, the calibration only works while the routers are on, a power cycle will change the physical configuration and the calibration will be lost.

To calibrate the data, there is an example. Just execute in MATLAB UbiLocate/matlab_scripts/calibrate_data/Calibrate_CSI_Data.m.

## Extracting the path parameters by MATLAB

We make public the algorithm for estimating the path parameters, Decompose. This algorithm corresponds to the one explained in Section 2.2 Angle estimation. There are two example in UbiLocate/matlab_scripts/Extract_Path_Parameters/. 

1) Handle_Decompose_2D: It decomposes the channel in 5 paths and extracts the parameters (AoA and path lenght)
2) Handle_Decompose_3D: It decomposes the channel in 5 paths and extracts the parameters (AoA, AoD and path lenght)


## Extracting ToF

This part extract the ToF for every pair of devices as explained in the paper 3.3 Implementation of the FTM procedure. Every device sends broadcast packets asynchronously every 4ms (if possible). This part is configured to send SISO packets, but it send 4x4 MIMO every 32 packets so that computing AoA and AoD at the same time as ToF is also possible. 

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
As for extractig the CSI, go to ToF and run these files:
```
bash reload.sh 
bash config.sh
bash start_cmd.sh
```

To extract the timestamps and the CSI, run this:
```
bash start_tof.sh name
```
where name is the name of the folder where the pcap files will be saved. By default, all the routers are transmitting until they collected 1000 packets at tcpdump.

NOTE1: Every bash file is configured with the login and pass as imdea.
Please change it. The variables are at the beggining of every file us and pw:
```
# ssh logins
us="imdea" # change it
ps="imdea" # change it
```

NOTE2: These scripts assume that there is one pair of routers 192.168.2.3 and 192.168.2.4.
Change the numbers:
```
ASUS="3 4"
```


If extracting ToF from more than one pair of routers is needed, just simple add more numbers at the end. Example ASUS="3 4 5"



Once this is done, the tof can be extracted by MATLAB. To do so:

```
UbiLocate/matlab_scripts/Extract_ToF/Save_Data.m
UbiLocate/matlab_scripts/Extract_ToF/Compute_ToF_music.m
```

The output of Compute_ToF_music.m is the ToF, variable ToF.

The CSI data for the full MIMO are saved in the variable csi_store_AoA

## Limitations

1) The router will reboot automatically when reload.sh is executed two times.

## FAQs

**1) What do the calibration values inside cal.mat mean?**

--> BP0_AoA: the measured beam-pattern at reception  in the direction 0 (perpendicular to the array)
--> BP0_AoD: same as BP0_AoA but at the transmittter side.
--> TX_delay_coef: the dalay at every transmitter antenna

After the calibration, you may need to refine the calibration. The values at the cal.mat are the ones that we measured. 

**2) What is the content of the reference80true.mat file in /matlab_scripts/Extract_ToF?**

It contais a CSI data template to remove the echos on the receiver side. To do so, we apply a deconvolution and that is why we use a hadamard division in the MATLAB code. The CSI data where captured by a pair of ASUS routers connecting the first chains of both (1's chain in device image, the rightmost chain on the ASUS).


**3) Can I use the 4X4 MIMO packets obtained every 32 packets by the ToF script as the reference CSI in the case of using coaxial cable and power divider?**

Yes, you can do it. The idea of extracting from time to time the CSI is to enable a join extraction of tof and CSI.
