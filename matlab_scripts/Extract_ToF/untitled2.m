clear all
close all
clc

s_toa = exp(1i*(1:256*2*2*pi)/256)
figure, plot(angle(s_toa))