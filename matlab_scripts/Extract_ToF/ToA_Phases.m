function [S_toa, times] = ToA_Phases(step_toa, K, BW, grid_active)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

    % a grid for the samples, where the maximum number of samples is 256
    % (n_fft). For a 80MHz and 256 as n_fft. The maximum delay of the
    % signal should be 256*(1/BW) = 3.2microseconds
    grid_delays = 0:step_toa:((K)-step_toa);
    
    % convert samples to time
    times = grid_delays*(1/BW)*1e3;

    % create the grid of the active subcarriers in term of the delays
    grid_carrier = repmat(grid_active, length(grid_delays),1);
    grid_toas = (grid_carrier).' .* grid_delays;

    % compute the phases
    S_toa = exp((-1i*grid_toas*2*pi)/K);

end

