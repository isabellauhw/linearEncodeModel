function Pxxc = confInterval(CL, Pxx, isXReal, w, fs, k)
%CONFINTERVAL Computes the confidence intervals of the power spectrum Pxx.
% This function is for internal use only. It may be removed.

%   Reference: D.G. Manolakis, V.K. Ingle and S.M. Kagon,
%   Statistical and Adaptive Signal Processing,
%   McGraw-Hill, 2000, Chapter 5

%   Copyright 2020 The MathWorks, Inc.
%#codegen

k = fix(k);
c = signal.internal.spectral.chi2conf(CL,k);
PxxcLower = Pxx*c(1);
PxxcUpper = Pxx*c(2);

% DC and Nyquist bins have only one degree of freedom for real signals
if isXReal
    realConf = signal.internal.spectral.chi2conf(CL,k/2);
    realConf1 = realConf(1);
    realConf2 = realConf(2);
    w0 = w == 0;
    PxxcLower(w0,:) = Pxx(w0,:) * realConf1;
    PxxcUpper(w0,:) = Pxx(w0,:) * realConf2;
    valueType = signalwavelet.internal.typeof(w);
    if isnan(fs)
        fPi = cast(pi, valueType);
        wPi = w == fPi;
        PxxcLower(wPi,:) = Pxx(wPi,:) * realConf1;
        PxxcUpper(wPi,:) = Pxx(wPi,:) * realConf2;
    else
        fFs = cast(fs/2, valueType);
        wFs = w == fFs;
        PxxcLower(wFs,:) = Pxx(wFs,:) * realConf1;
        PxxcUpper(wFs,:) = Pxx(wFs,:) * realConf2;
    end
end
Pxxc = reshape([PxxcLower; PxxcUpper],size(Pxx,1),2*size(Pxx,2));
end