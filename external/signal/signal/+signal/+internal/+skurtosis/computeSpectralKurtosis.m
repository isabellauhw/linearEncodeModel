function [SK, threshold] = computeSpectralKurtosis(P, fs, f, window, confidenceLevel)
%COMPUTESPECTRALKURTOSIS compute engine for spectral kurtosis
%
% P - matrix, power spectrogram of x (nonnegative and real)
% fs - sampling frequency
% f - frequency vector
% window - window size for STFT
% confidenceLevel - confidence level for Gaussian white noise

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

M4 = mean(P.^2, 2);
M2 = mean(P, 2);
K = size(P, 2);
if K < 2
    SK = M4./M2.^2 - 2;
else
    SK = (K+1)/(K-1)*M4./M2.^2 - 2;  % STFT-based Estimate (with correcting bias)
end
SK(f <= fs/window) = 0;        % SK is set to 0 near f=0
SK(f >= (fs/2 - fs/window)) = 0; % SK is set to 0 near f=fs/2 (Nyquist)
alpha = 1 - confidenceLevel;
threshold = -sqrt(2)*erfcinv(2*(1-alpha/2))*2/sqrt(K);
