clear 
close all
clc



%% csireader.m
%
% read and plot CSI from UDPs created using the nexmon CSI extractor (nexmon.org/csi)
% modify the configuration section to your needs
% make sure you run >mex unpack_float.c before reading values from bcm4358 or bcm4366c0 for the first time
%
% the example.pcap file contains 4(core 0-1, nss 0-1) packets captured on a bcm4358
%

%% configuration
CHIP = '4366c0';          % wifi chip (possible values 4339, 4358, 43455c0, 4366c0)

if ishandle(1),
  close(1);
end;

BW = 80;                % bandwidth



FILE = strcat("../../traces/test_1ss/trace4.pcap");% capture file
% FILE = './trace.pcap';% capture file

csi_data = read_pcap_1(FILE,BW);

% plot the absolute value
figure,
for ii = 1:4
    subplot(4,1,ii)
    plot(squeeze(abs(csi_data(1,:,ii))))
end

