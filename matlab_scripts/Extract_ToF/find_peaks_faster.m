function [peaks,position_peaks] = find_peaks_faster(spectrum)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    diff_spectrum = diff(spectrum);
    index_positive = double(diff_spectrum > 0);
    diff_positive = diff(index_positive);
    diff_positive_positions = find(diff_positive < 0);
    peaks = spectrum(diff_positive_positions +1);
    position_peaks = diff_positive_positions+1;
end

