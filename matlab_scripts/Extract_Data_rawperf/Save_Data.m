
close all 
clc
clear


%% configuration
BW = 80;                % bandwidth

      
        
%% 1 spatial stream
FILE = strcat("../../traces/test_1ss_rawperf/trace4.pcap");% capture file
[csi_store, toa_packets] = load80MHZ(FILE, BW);
packets = length(csi_store);
K = length(csi_store{1,1}.core{1,1}.nss{1,1}.data);
N = sum(de2bi(csi_store{1,1}.core_config));
M = sum(de2bi(csi_store{1,1}.nss_config));
csi_data = zeros(packets, K, N,M);


for ii = 1:packets
    for jj = 1:N
        for kk = 1:M
            csi_data(ii,:,jj,kk) = csi_store{1,ii}.core{1,jj}.nss{1,kk}.data;
        end
    end
end
csi_data = squeeze(csi_data);
csi_data = csi_data(2:end,:,:,:);
packets = packets -1;
toa_packets = toa_packets(2:end);

% The csi data is inside the variable csi data and the toa_packets means
% the time of arrival of the packets. Save both.

%% 4 spatial stream
FILE = strcat("../../traces/test_4ss_rawperf/trace4.pcap");% capture file
[csi_store, toa_packets] = load80MHZ(FILE, BW);
packets = length(csi_store);
K = length(csi_store{1,1}.core{1,1}.nss{1,1}.data);
N = sum(de2bi(csi_store{1,1}.core_config));
M = sum(de2bi(csi_store{1,1}.nss_config));
csi_data = zeros(packets, K, N,M);


for ii = 1:packets
    for jj = 1:N
        for kk = 1:M
            csi_data(ii,:,jj,kk) = csi_store{1,ii}.core{1,jj}.nss{1,kk}.data;
        end
    end
end
csi_data = squeeze(csi_data);
csi_data = csi_data(2:end,:,:,:);
packets = packets -1;
toa_packets = toa_packets(2:end);

% The csi data is inside the variable csi data and the toa_packets means
% the time of arrival of the packets. Save both.

