%% csireader.m
%
% read and plot CSI from UDPs created using the nexmon CSI extractor (nexmon.org/csi)
% modify the configuration section to your needs
% make sure you run >mex unpack_float.c before reading values from bcm4358 or bcm4366c0 for the first time
%

clear
close all
clc

%% configuration
CHIP = '4366c0';          % wifi chip (possible values 4339, 4358, 43455c0, 4366c0)
BW = 80;                % bandwidth
ss = 4;
N = 4;



FILE = strcat("../../traces/test_4ss/./trace4.pcap");

[cmplxall_raw_all] = read_pcap_4(FILE,BW);

[packets,K,~] = size(cmplxall_raw_all);

csi_data = zeros(packets,K,N,ss);

for jj = 1:packets
    for ii = 1:N
        csi_data(jj,:,ii,:) = cmplxall_raw_all(jj,:,(((ii-1)*N)+1):((ii*N)-(N-ss)));
    end
end

figure, 
% plot the absolute value
string_title = "Spatial stream:";
string_title = strcat(repmat(string_title,1,4), string(1:4));
string_title = repmat(string_title,4,1);
string_chains = strcat(" RX chain:",repmat(string(1:4).',1,4));
string_title = strcat(string_title,string_chains);
counter = 0;
for ii = 1:4
    for jj=1:4
        counter = counter + 1;
        subplot(4,4,counter)
        plot(squeeze(abs(csi_data(1,:,ii,jj))))
        title(string_title(ii,jj))
    end
end

