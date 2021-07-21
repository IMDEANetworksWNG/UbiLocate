% close all 
clc
clear

% tof8meter = -2.976774292566268e-06;
% tof8meter = -3.489733755537262e-06;
tof8meter = -2.845524292566268e-06;
clight = 2e8;
dist0 = 8;


% grid for the active subcarriers
 grid_active = [-122, -121, -120, -119, -118, -117, -116, -115, -114, -113, -112, -111, -110, ...
-109, -108, -107, -106, -105, -104, -102, -101, -100, -99, -98, -97, -96, -95, ...
-94, -93, -92, -91, -90, -89, -88, -87, -86, -85, -84, -83, -82, -81, -80, -79, ...
-78, -77, -76, -74, -73, -72, -71, -70, -69, -68, -67, -66, -65, -64, -63, -62, ...
-61, -60, -59, -58, -57, -56, -55, -54, -53, -52, -51, -50, -49, -48, -47, -46, ...
-45, -44, -43, -42, -41, -40, -38, -37, -36, -35, -34, -33, -32, -31, -30, -29, ...
-28, -27, -26, -25, -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, ...
-12, -10, -9, -8, -7, -6, -5, -4, -3, -2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, ...
17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, ...
40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, ...
62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 76, 77, 78, 79, 80, 81, 82, 83, 84, ...
85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 104, 105, ...
106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, ...
122];


%% configuration
BW = 80;                % bandwidth

load("Data_tof.mat")

% for id_point = 1:length(points_str)

load(sprintf('reference80true.mat', BW)); 
reference = reference.';

K = 256;


% number of sensors for smoothing
n_sensors = 50;

% take the matrix of toa phases
[S_toa, times] = ToA_Phases(0.1, K, 80, 1:n_sensors);
% take the matrix of toa phases
step_toa = 0.1;
[~,len_toa] = size(S_toa);

limit_time = K*(1/BW)*1e3;


peak_default = 1;

for ab = ["A", "B"]
    
    eval(strcat("[packets,~] = size(correz",ab,");"))
    eval(strcat("correz_",ab,"_MUSIC = zeros(packets,1);"))

    for id_packet = 1:packets
    %         tic
        % take the csi
        eval(strcat("csi_test = csi_store", ab,"{id_packet};"))
        eval(strcat("csi_test = csi_store", ab,"{id_packet};"))
        csi_test = csi_test.core{1,1}.nss{1,1}.data;
        % calibrate it
        csi_test = csi_test./reference;
        
        % create the a csi for doing an IFFT and check where is the power
        % in time, so that the grid search of MUSIC is faster
        csi_test_time = zeros(K,1);
        csi_test_time(grid_active + K/2 + 1) = csi_test(grid_active + K/2 + 1);
        csi_test_time = ifft(csi_test_time);

        % take the index of the max
        [~,index_max] = max(abs(csi_test_time));
        index_max = (index_max -1) * 10 + 1;
        % take a time window 400ns --> 32*12.5. 12-5 = 1/BW
        index_toa = zeros(32/step_toa,1);
        index_toa(:,1) = ((index_max-1)- (16/(step_toa))):((index_max-2) + (16/(step_toa)));
        index_toa(:,1) = mod(index_toa, len_toa)+1;


        % take only active subcarriers
        csi_test = csi_test(grid_active + K/2 + 1);


        % before computing the smoothed correlation matrix, it is needed to
        % interpolate the values of the missing subcarriers

        % subcarrier position to interpolate
        xq = [-103,-75,-39,-11,-1,0,1,11,39,75,103];

        % initialize the variable to save the channel +  interpolated values
        csi_test_interp = zeros(length(grid_active)+length(xq),1);

        % indexes
        index_active = grid_active + (K-12)/2 + 1;
        index_non_active = xq + (K-12)/2 + 1;

        % linear interpolation for smoothing
        vq = interp1(grid_active, csi_test, xq);
        % take the values
        csi_test_interp(index_active,1) = csi_test;
        csi_test_interp(index_non_active,1) = vq;

        % compute the smoothed correlation matrix in time domain
        % variable to select forward and backword smoothing, if not 0 means only
        % forward
        isFB = 1;

        [R_time] = Smoothing_1D_faster(csi_test_interp,n_sensors, isFB);

        % hard-coding!
        n_signals = 5;

        % reduce the grid
        S_toa_reduced = S_toa(:,index_toa);

        % compute the MUSIC spectrum
        [spectrum] = MUSIC(R_time, S_toa_reduced, n_signals);


        % take the peaks
        [PKS,LOCS]= find_peaks_faster(spectrum);

        LOCS = index_toa(LOCS);

        if(max(PKS) ~= max(spectrum))
            [max_value, index_max] = max(spectrum);
            PKS(end+1) = max_value;
            LOCS(end+1) = index_max;
        end

        %  remove the weakest peaks
        th = min(spectrum) + (1/3)*(max(PKS)-min(PKS));
        index_remove = PKS < th;

        PKS(index_remove) = [];
        LOCS(index_remove) = [];

        % order the time of arrival
        [LOCS, index_sort] = sort(LOCS, "ascend");
        PKS = PKS(index_sort);

        peak_times = times(LOCS);

        % check whether the time is negative
        diff_time = diff(peak_times);
        index_change = find(abs(diff_time) > 1000);

        if (isempty(index_change) == false)
            peak_times((index_change+1):end) = peak_times((index_change+1):end) - limit_time;

        end

        [peak_times_sort, index_sort] = sort(peak_times);


        % take the first to arrive
        peak = 1;

        if (isempty(index_sort))
            diffs = 0;
        else
            S_toa_test = S_toa(:,LOCS(index_sort(peak)));

            phase_toa_test = unwrap(angle(S_toa_test));
            diffs = diff(phase_toa_test);
        end
        % get the delay to be substracted from the CSI data
        eval(strcat("correz_",ab,"_MUSIC(id_packet,1) = median(diffs) / 2 / pi / 312.5e3;"))
    %          correz_A_MUSIC(id_packet,1) = median(diffs) / 2 / pi / 312.5e3;

    end
    % substract the delay
    eval(strcat("rxtshfc",ab," = rxtshfc",ab," -  correz_",ab,"_MUSIC;"))
end


startTimeAtNodeA = min([min(rxtshfcA) min(txtshfcB)]);
startTimeAtNodeB = min([min(rxtshfcB) min(txtshfcA)]);


rxtshfcA = rxtshfcA - startTimeAtNodeA;
txtshfcB = txtshfcB - startTimeAtNodeA;
rxtshfcB = rxtshfcB - startTimeAtNodeB;
txtshfcA = txtshfcA - startTimeAtNodeB;

% fix aoa times similarly
rxtshfcA_aoa = rxtshfcA_aoa - startTimeAtNodeA;
rxtshfcB_aoa = rxtshfcB_aoa - startTimeAtNodeB;

%---------
% disp 'now running quickcalc'

Twin = 0.1;
tstart = rxtshfcA(1);
tofAB = [];
timetof = [];
timeref = [];

margin = 0;

while 1,
tend = tstart + Twin;
subindexesA = find(rxtshfcA > tstart & rxtshfcA < tend);
subindexesB = find(txtshfcB > (tstart - margin) & txtshfcB < (tend + margin));

if tstart > max(rxtshfcA),
break;
end;
if length(subindexesA) > 0 & length(subindexesB) > 0,
rxtshfcA_sub = rxtshfcA(subindexesA);
txtshfcA_sub = txtshfcA(subindexesA);
txtshfcB_sub = txtshfcB(subindexesB);
rxtshfcB_sub = rxtshfcB(subindexesB);

% calcolo skew A->B
Ycolv = txtshfcA_sub;
Xcolv = rxtshfcA_sub;
Const = ones(size(Xcolv));
Coeffs = [Xcolv Const]\Ycolv;
mAB = Coeffs(1);

rxtshfcA_sub = mAB * rxtshfcA_sub;
txtshfcB_sub = mAB * txtshfcB_sub;

for kk = 1:length(rxtshfcA_sub),
  % trova tempo t1 e t2
  rxBatA = rxtshfcA_sub(kk);
  txB = txtshfcA_sub(kk);
  % ora cerca il tempo di trasmissione di A successivo a rxBatA
  indtmp = find(txtshfcB_sub > rxBatA);
  if isempty(indtmp),
    continue;
  end;
  txA = txtshfcB_sub(indtmp(1));
  rxAatB = rxtshfcB_sub(indtmp(1));

  tof = ( (rxAatB - txB) - (txA - rxBatA) ) / 2;
  tofAB = [tofAB tof];
%       timeref = [tim
  timetof = [timetof rxAatB];
end;
end;

tstart = tstart + Twin;
end;
clight = 3e8;

lengthABs = ((tofAB) - tof8meter) * clight + dist0;
ToF = median(lengthABs)
