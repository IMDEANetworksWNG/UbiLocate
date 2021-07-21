close all 
clc
clear


%% configuration
BW = 80;                % bandwidth

VSA='0003';
VSB='0004';


% file to extract tof
FILEA = strcat("test_tof/trace4.pcap");
FILEB = strcat("test_tof/trace3.pcap");

% extract timestamps and CSI. csi_storeA means the CSI for the full MIMO
% for the node A, in this case the one from router 4
% CSI matrix 
[rxtshfcA rxtssfcA csi_storeA sncsisA txtshfcA packetsA correzA csi_storeA_aoa rxtshfcA_aoa rxtssfcA_aoa] = load80MHZstudio_no_correz(FILEA, BW, VSA);
[rxtshfcB rxtssfcB csi_storeB sncsisB txtshfcB packetsB correzB csi_storeB_aoa rxtshfcB_aoa rxtssfcB_aoa] = load80MHZstudio_no_correz(FILEB, BW, VSB);

% save it
save("Data_tof");

