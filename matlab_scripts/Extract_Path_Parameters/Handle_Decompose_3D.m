close all
clc
clear



% load the file
load("csi_data.mat")

% BW in MHz
BW = 80;

% # of packets, subcarriers, RX chains and spatial streams
[packets, K, N, M] = size(csi_data);


% number of path to extract
n_paths = 5;
% take the first packet
csi_data_aux = csi_data(1,:,:,:);

% apply decompose. Output: AoA, AoD, attenuation and path length
[AoA, AoD, att, path_length] = Decompose_3D(csi_data_aux, n_paths);

AoA = real(asin(AoA/pi)*180/pi);
AoD = real(asin(AoD/pi)*180/pi);
path_length = (((path_length)*K)*(1/(BW*1e6)))*(1e9); % in nanoseconds
power = abs(att).^2;


% maybe the first path is nor the correct path from the client. We select
% it as follows:

% theshold for the power. 
th = 3;

metric = squeeze(power(2) ./ power(1));
index_th = metric >= th;

if (index_th == 1)
    index_sort = [2 1];
else
    index_sort = [1 2];
end

AoA(1:2) = AoA(index_sort);
AoD(1:2) = AoD(index_sort);
path_length(1:2) = path_length(index_sort);
att(1:2) = att(index_sort);
power(1:2) = power(index_sort);
