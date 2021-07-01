%%
% tof8meter = -2.976774292566268e-06;
% tof8meter = -3.489733755537262e-06;
tof8meter = -2.845524292566268e-06;
clight = 2e8;
dist0 = 8;

%% configuration
BW = 80;                % bandwidth
FILEA = './trace10vs4fast_80_dicembre30_2.pcap';
FILEB = './trace4vs10fast_80_dicembre30_2.pcap';

[rxtshfcA rxtssfcA csi_storeA sncsisA txtshfcA packetsA correzA] = load80MHZ(FILEA, BW);
[rxtshfcB rxtssfcB csi_storeB sncsisB txtshfcB packetsB correzB] = load80MHZ(FILEB, BW);

% adesso il nodo A e' il 10, il B e' il 4
% A contiene tempi di ricezione del nodo A e i corrispondenti tempi di trasmissione al nodo B
% B contiene tempi di ricezione del nodo B e i corrispondenti tempi di trasmissione al nodo A

startTimeAtNodeA = max([max(rxtshfcA) max(txtshfcB)]);
startTimeAtNodeB = max([max(rxtshfcB) max(txtshfcA)])

rxtshfcA = startTimeAtNodeA - rxtshfcA;
txtshfcB = startTimeAtNodeA - txtshfcB;
rxtshfcB = startTimeAtNodeB - rxtshfcB;
txtshfcA = startTimeAtNodeB - txtshfcA;

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
