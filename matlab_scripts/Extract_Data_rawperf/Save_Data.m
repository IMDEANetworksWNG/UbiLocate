
close all 
clc
clear

% addpath("../functions")

%% configuration
BW = 80;                % bandwidth


name_folder = "test_github_4ss";

routers_csi = string([4]);
routers_csi_num = [4];

routers = (1:length(routers_csi));

folder = "";
VSA='0003';
VSB='000';

mkdir("../mat_files")


for id_point = 1:length(name_folder)
    mkdir(strcat("../mat_files/", name_folder(id_point)))

    for id_router = routers
        
        [id_point, id_router]
        
        VSB(4) = lower(dec2hex(routers_csi_num(id_router)));
        VSB
        
        FILEA = strcat("../../traces/",name_folder(id_point),"/trace",routers_csi(id_router),".pcap")
%         [rxtshfcA rxtssfcA csi_storeA sncsisA txtshfcA packetsA correzA] = load80MHZ_new_no_correz(FILEA, BW);
        [csi_store, toa_packets] = load80MHZ(FILEA, BW, VSA);
        packets = length(csi_store);
        K = length(csi_store{1,1}.core{1,1}.nss{1,1}.data);
        N = sum(de2bi(csi_store{1,1}.core_config));
        M = sum(de2bi(csi_store{1,1}.nss_config));
        csi_data = zeros(packets, K, N,M);
%         csi_data_calibrated = zeros(packets, K, N);

        for ii = 1:packets
            for jj = 1:N
                for kk = 1:M

                csi_data(ii,:,jj,kk) = csi_store{1,ii}.core{1,jj}.nss{1,kk}.data;
%                 csi_data_calibrated(ii,:,jj) = csi_data(ii,:,jj)./(csi_storeA_aoa{1,1}.core{1,jj}.nss{1,1}.data).';
                end
            end
        end
        csi_data = squeeze(csi_data);
        csi_data = csi_data(2:end,:,:,:);
        packets = packets -1;
        toa_packets = toa_packets(2:end);
        save(strcat("../mat_files/",name_folder(id_point),"/csi_data"), "csi_data", "toa_packets")

        
    end
end

for packet_id = 1:10

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
        plot(squeeze(abs(csi_data(packet_id,:,ii,jj))))
        title(string_title(ii,jj))
    end
end
figure, plot(angle(squeeze(csi_data(packet_id,:,1,1))./squeeze(csi_data(packet_id,:,1,2))))
figure, plot(angle(squeeze(csi_data(packet_id,:,1,1))./squeeze(csi_data(packet_id,:,2,1))))

end