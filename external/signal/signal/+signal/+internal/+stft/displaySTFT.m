function displaySTFT(T,F,S,opts)
% DISPLAYSTFT Plots Short-time Fourier transform.
% This function is for internal use only. It may be removed.

%   Copyright 2020 The MathWorks, Inc.
%#codegen

% Plot options
    plotOpts.isFsnormalized = opts.IsNormalizedFreq;

    % The function plotTFR has its own scaling. Remove scaling as necessary to
    % provide plotTFR with expected inputs.
    if plotOpts.isFsnormalized
        if ~strcmp(opts.FreqRange,'centered')
            timeScale = 1/(2*pi);
            freqScale = pi;
            T = T.*timeScale;
            F = F.*freqScale;
        end
    end
    plotOpts.cblbl = getString(message('signal:dspdata:dspdata:MagnitudedB'));
    plotOpts.title = getString(message('signal:stft:titleSTFT'));
    plotOpts.threshold = max(20*log10(abs(S(:))+eps))-60;

    % Magnitude (dB)
    signalwavelet.internal.convenienceplot.plotTFR(T,F,20*log10(abs(S)+eps),plotOpts);

end