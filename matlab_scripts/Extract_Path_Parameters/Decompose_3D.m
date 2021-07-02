function [AoA, AoD, Power, T] = Decompose_3(csi_data, N_paths)
if nargin < 2
    N_paths = 5;
end
%% Load calibration
load('Cal.mat', 'BP0_AoA', 'BP0_AoD', 'TX_delay_coef')

[~,n_sub, n_rx, n_tx] = size(csi_data);

BP0_AoA = BP0_AoA(1:n_rx);
BP0_AoD = BP0_AoD(1:n_tx);
index_tx = [3, 1, 4, 2];
if (n_rx == 3)
    index_tx = [3, 1, 2];
    TX_delay_coef = TX_delay_coef([1,2,4]);

end

if (n_rx == 2)
    index_tx = [1, 2];
    TX_delay_coef = TX_delay_coef([2,4]);

end
% index_tx = index_tx(1:n_rx);

%% Beamforming codebooks
%% Discrete angle domain
Angle = linspace(-pi, pi, 4*1024);
BP_AoA = BP0_AoA.*exp(1i*(0:(n_rx-1)).'*Angle)/norm(BP0_AoA);
BP_AoD = BP0_AoD.*exp(1i*(0:(n_tx-1)).'*Angle)/norm(BP0_AoD);
%% Find nan possitions and fill them with 0
I_nan = find(isnan(csi_data(1, :, 1, 1)));
csi_data(:, I_nan, :, :) = 0;
%% ToA TX correction
if (n_tx == 2)
    permutation = zeros(1,n_sub,n_tx);
    permutation(1,:,:) = permute(exp(-(1:size(csi_data, 2)).'*TX_delay_coef*2*pi*1i), index_tx);
    csi_data = csi_data.*permutation;
else
    csi_data = csi_data.*permute(exp(-(1:size(csi_data, 2)).'*TX_delay_coef*2*pi*1i), index_tx);
end

%% ToA equallization (strongest path to t=0)
csi_data_fft = fft(csi_data, 4*1024, 2);
csi_data_t_spectrum = sum(abs(csi_data_fft(:, :, :)).^2, 3);
[~, I] = max(csi_data_t_spectrum, [], 2);
csi_data = csi_data.*exp(-(I-1)*(1:size(csi_data, 2))*2*pi*1i/(4*1024));
%% Reduction by singular vector
[~, S, V] = svd(csi_data(:, :), 'econ');
csi_data_0 = reshape(V(:, 1)*S(1), n_sub, n_rx, n_tx)/sqrt(size(csi_data, 1));
csi_data_00 = csi_data_0; % Save for later
%% Initialization
AoA = zeros(1, N_paths);
AoD = zeros(1, N_paths);
Power = zeros(1, N_paths);
T = zeros(1, N_paths);
%% MP loop
for ii_path = 1:N_paths
    %% Time analysis
    csi_data_t = fft(csi_data_0, 4*1024, 1);
    Time_spectrum = sum(abs(csi_data_t(:, :)).^2, 2);
    [~, t] = max(Time_spectrum);
    %% Spatial analysis
    Ht = squeeze(csi_data_t(t, :, :));
    %% AoD estimation
    AoD_Spectrum = sum(abs(Ht*BP_AoD).^2, 1);
    [~, ii_AoD] = max(AoD_Spectrum);
    AoA_Spectrum = (Ht*BP_AoD(:, ii_AoD))'*BP_AoA;
    [~, ii_AoA] = max(abs(AoA_Spectrum));
    AoD_Spectrum = BP_AoA(:, ii_AoA)'*Ht*BP_AoD;
    [~, ii_AoD] = max(abs(AoD_Spectrum));
    AoA_Spectrum = (Ht*BP_AoD(:, ii_AoD))'*BP_AoA;
    [~, ii_AoA] = max(abs(AoA_Spectrum));
    %% Channel reconstruction
    csi_reconst_t = zeros(size(csi_data_t));
    csi_reconst_t(t, :, :) = BP_AoA(:, ii_AoA)*BP_AoD(:, ii_AoD)';
    csi_reconst_0 = ifft(csi_reconst_t, 4*1024, 1);
    csi_reconst_0 = csi_reconst_0(1:n_sub, :, :);
    csi_reconst_0(I_nan, :, :) = 0;
    csi_reconst_0(:);
    alpha = csi_reconst_0(:)'*csi_data_0(:)/norm(csi_reconst_0(:));
    %% Dump
    AoA(ii_path) = Angle(ii_AoA);
    AoD(ii_path) = Angle(ii_AoD);
    Power(ii_path) = alpha;
    T(ii_path) = (t-1)/(4*1024);
    %% Projection
    csi_data_0 = csi_data_0 - csi_reconst_0*(alpha/norm(csi_reconst_0(:)));
end
%% Optimization definition
    function h = computeh(AoA, AoD, T)
        BA = BP0_AoA.*exp(1i*(0:(n_rx-1)).'*AoA);         % AoA response
        BDC = conj(BP0_AoD).*exp(-1i*(0:(n_tx-1)).'*AoD); % AoD conjugate response
        FS = exp(2i*pi*(0:(n_sub-1)).'*T);               % Frequency response
        FS(I_nan) = 0;
        h = kron(kron(BDC, BA), FS);
    end

    function H = computeH(x)
        A = x(1:N_paths);
        D = x(N_paths+1:2*N_paths); 
        TF = x(2*N_paths+1:3*N_paths);
        H = zeros(prod([n_sub,n_rx,n_tx]), N_paths);
        for iii_path = 1:N_paths
            H(:, iii_path) = computeh(A(iii_path), D(iii_path), TF(iii_path));
        end
    end

    function fval = costx(x)
        H = computeH(x);
%         H_orth = orth(H);
%         fval = -norm(H_orth'*csi_data_00(:)).^2;
        aa = H\csi_data_00(:);
        regularization = 1;
        fval = norm(csi_data_00(:)-H*aa)+regularization*norm(aa);
    end
%% Optimization
x = fminsearch(@costx, [AoA, AoD, T].', optimset('Display', 'none'));
%% Solution retrieval
HH = computeH(x);
HH = HH/norm(HH(:, 1));
Power = HH\csi_data_00(:);
AoA = x(1:N_paths);
AoD = x(N_paths+1:2*N_paths);
T = x(2*N_paths+1:3*N_paths);
%% Paths sorting
T = rem(T + 0.5, 1);
[~, II] = sort(T-0.001*abs(Power)/max(abs(Power)));
T = T(II);
AoA = AoA(II);
AoD = AoD(II);
Power = Power(II);
%% Avoid first spurious path
Rotation = [2:N_paths, 1];
while abs(Power(1)*5) < max(abs(Power))
    Power = Power(Rotation);
    AoA = AoA(Rotation);
    AoD = AoD(Rotation);
    T = T(Rotation);
end
%% Normallize domains
AoA = rem(AoA + pi, 2*pi) - pi;
AoD = rem(AoD + pi, 2*pi) - pi;
T = T - T(1);
end