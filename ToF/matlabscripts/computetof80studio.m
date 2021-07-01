%%
% tof8meter = -2.976774292566268e-06;
% tof8meter = -3.489733755537262e-06;
tof8meter = -2.845524292566268e-06;
clight = 2e8;
dist0 = 8;

%% configuration
BW = 80;                % bandwidth
% FILEA = './trace10vs4_80_gennaio06_1.pcap';
% FILEB = './trace4vs10_80_gennaio06_1.pcap';
% FILEA = './trace10vs4fast_80_gennaio06_2.pcap';
% FILEB = './trace4vs10fast_80_gennaio06_2.pcap';
% FILEA = './trace10vs4slow_80_gennaio06_3.pcap';
% FILEB = './trace4vs10slow_80_gennaio06_3.pcap';
% FILEA = './trace10vs4slowid_80_gennaio06_5.pcap';
% FILEB = './trace4vs10slowid_80_gennaio06_5.pcap';
% FILEA = './trace11vs4slowid_80_gennaio06_6.pcap';
% FILEB = './trace4vs11slowid_80_gennaio06_6.pcap';

% VSALL 4-11
FILEA = './trace11vsALLslowid_80_gennaio06_7.pcap'; VSA='0004';
FILEB = './trace4vsALLslowid_80_gennaio06_7.pcap';  VSB='000b';

% VSALL 4-10
% FILEA = './trace10vsALLslowid_80_gennaio06_7.pcap'; VSA='0004';
% FILEB = './trace4vsALLslowid_80_gennaio06_7.pcap';  VSB='000a';

[rxtshfcA rxtssfcA csi_storeA sncsisA txtshfcA packetsA correzA csi_storeA_aoa rxtshfcA_aoa rxtssfcA_aoa] = load80MHZstudio(FILEA, BW, VSA);
[rxtshfcB rxtssfcB csi_storeB sncsisB txtshfcB packetsB correzB csi_storeB_aoa rxtshfcB_aoa rxtssfcB_aoa] = load80MHZstudio(FILEB, BW, VSB);

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
% calcolo skew A->B
Ycolv = txtshfcA;
Xcolv = rxtshfcA;
Const = ones(size(Xcolv));
Coeffs = [Xcolv Const]\Ycolv;
mAB = Coeffs(1);

rxtshfcA = mAB * rxtshfcA;
txtshfcB = mAB * txtshfcB;

tofAB = [];
timetof = [];

distanze = [];

for kk = 1:length(rxtshfcA),
  % trova tempo t1 e t2
  rxBatA = rxtshfcA(kk);
  txB = txtshfcA(kk);
  % ora cerca il tempo di trasmissione di A successivo a rxBatA
  indtmp = find(txtshfcB > rxBatA);
  if isempty(indtmp),
    continue;
  end;
  txA = txtshfcB(indtmp(1));
  rxAatB = rxtshfcB(indtmp(1));

  distanze = [distanze (txA - rxBatA)];

  tof = ( (rxAatB - txB) - (txA - rxBatA) ) / 2;
  tofAB = [tofAB tof];
  timetof = [timetof rxBatA];
end;


lengthABs = ((tofAB) - tof8meter) * clight + dist0;
lengthAB = mean(lengthABs);
