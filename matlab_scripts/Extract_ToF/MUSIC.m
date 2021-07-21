function [ps_db, D] = MUSIC(R, S, n_signals)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    % Estimate eigen-values and eiugen-vectors by an eigen decomposition
    [U,D] = eig(R);
    % take the eigen-values
    D = diag(D);
    % sort in power
    [D,ind] = sort(D, 'descend');
    % sort the eigen-vector
    U = U(:,ind); 

    % It is needed to estimate the noise space, taking into account that we
    % have D signals. The noise space should be a matrix of Nx(N-D)
    Un = U(:,(n_signals+1):end);

    % Compute the pseudo-spectrum
    ps = sum(abs((S')*Un).^2,2);
    ps = ps.^-1;


    % move to dB scale
    ps_db = 10*log10(ps);


end

