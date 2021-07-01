%%
% tof8meter = -2.976774292566268e-06;
% tof8meter = -3.489733755537262e-06;
tof8meter = -2.845524292566268e-06;
clight = 2e8;
dist0 = 8;

%% configuration
BW = 80;                % bandwidth
% FILEA = './trace5vs3slow_80_gennaio04_3.pcap';
% FILEB = './trace3vs5slow_80_gennaio04_3.pcap';
% FILEA = './pcap_files/trace3.pcap';
% FILEB = './pcap_files/trace10.pcap';
% FILEA = './trace5vs3slow_80_gennaio05_4.pcap';
% FILEB = './trace3vs5slow_80_gennaio05_4.pcap';
% FILEA = './trace5vs3slow_80_gennaio05_5.pcap';
% FILEB = './trace3vs5slow_80_gennaio05_5.pcap';
FILEA = './trace5vs3slow_80_gennaio05_9.pcap';
FILEB = './trace3vs5slow_80_gennaio05_9.pcap';

[rxtshfcA rxtssfcA csi_storeA sncsisA txtshfcA packetsA correzA csi_storeA_aoa rxtshfcA_aoa rxtssfcA_aoa] = load80MHZstudio(FILEA, BW, '789b');
[rxtshfcB rxtssfcB csi_storeB sncsisB txtshfcB packetsB correzB csi_storeB_aoa rxtshfcB_aoa rxtssfcB_aoa] = load80MHZstudio(FILEB, BW, '789b');

% adesso il nodo A e' il 10, il B e' il 4
% A contiene tempi di ricezione del nodo A e i corrispondenti tempi di trasmissione al nodo B
% B contiene tempi di ricezione del nodo B e i corrispondenti tempi di trasmissione al nodo A

startTimeAtNodeA = max([max(rxtshfcA) max(txtshfcB)]);
startTimeAtNodeB = max([max(rxtshfcB) max(txtshfcA)])

rxtshfcA = startTimeAtNodeA - rxtshfcA;
txtshfcB = startTimeAtNodeA - txtshfcB;
rxtshfcB = startTimeAtNodeB - rxtshfcB;
txtshfcA = startTimeAtNodeB - txtshfcA;

% fix aoa times similarly
rxtshfcA_aoa = startTimeAtNodeA - rxtshfcA_aoa;
rxtshfcB_aoa = startTimeAtNodeB - rxtshfcB_aoa;

%---------
disp 'now running quickcalc'
quickcalc;

