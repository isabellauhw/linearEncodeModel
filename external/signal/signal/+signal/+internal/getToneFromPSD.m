function [power, freq, idxTone, idxLeft, idxRight] = getToneFromPSD(Pxx, F, rbw, toneFreq)
%GETTONEFROMPSD Retrieve the power and frequency of a windowed sinusoid
%
%  This function is for internal use only and may be removed in a future
%  release of MATLAB

%   Copyright 2013-2019 The MathWorks, Inc.

%#codegen

idxTone = []; idxLeft = []; idxRight = [];
coder.varsize('idxTone','idxLeft','idxRight',[1,1],[1,1]);

% force column vector
colPxx = Pxx(:);
colF = F(:);

if nargin<4
    [~, idxTone] = max(colPxx);
elseif colF(1) <= toneFreq(1) && toneFreq(1) <= colF(end)
    % find closest bin to specified freq
    [~, idxTone] = min(abs(colF-toneFreq(1)));
    % look for local peak in vicinity of tone
    iLeftBin = max(1,idxTone(1)-1);
    iRightBin = min(idxTone(1)+1,numel(colPxx));
    [~, idxMax] = max(colPxx(iLeftBin:iRightBin));
    idxTone = iLeftBin+idxMax-1;
else
    power = NaN('like',Pxx);
    freq = NaN('like',Pxx);
    idxTone = [];
    idxLeft = [];
    idxRight = [];
    return
end

idxToneScalar = idxTone(1);

% sidelobes treated as noise
idxLeft = idxToneScalar - 1;
idxRight = idxToneScalar + 1;

% roll down slope to left
while idxLeft(1) > 0 && colPxx(idxLeft(1)) <= colPxx(idxLeft(1)+1)
    idxLeft = idxLeft - 1;
end

% roll down slope to right
while idxRight(1) <= numel(colPxx) && colPxx(idxRight(1)-1) >= colPxx(idxRight(1))
    idxRight = idxRight + 1;
end

% provide indices to the tone border (inclusive)
idxLeft = idxLeft+1;
idxRight = idxRight-1;

idxLeftScalar = idxLeft(1);
idxRightScalar = idxRight(1);

% compute the central moment in the neighborhood of the peak
Ffund = colF(idxLeftScalar:idxRightScalar);
Sfund = colPxx(idxLeftScalar:idxRightScalar);
freq = dot(Ffund, Sfund) ./ sum(Sfund);

% report back the integrated power in this band
if idxLeftScalar<idxRightScalar
    % more than one bin
    power = bandpower(colPxx(idxLeftScalar:idxRightScalar),colF(idxLeftScalar:idxRightScalar),'psd');
elseif 1 < idxRightScalar && idxRightScalar < numel(colPxx)
    % otherwise just use the current bin
    power = colPxx(idxRightScalar) * (colF(idxRightScalar+1) - colF(idxRightScalar-1))/2;
else
    % otherwise just use the average bin width
    power = colPxx(idxRightScalar) * mean(diff(colF));
end

% protect against nearby tone invading the window kernel
if nargin>2 && power < rbw(1)*colPxx(idxToneScalar)
    power = rbw(1)*colPxx(idxToneScalar);
    freq = colF(idxToneScalar);
end