function opts = getAndValidateFrequencyResolution(opts)
% Get and validate FrequencyResolution parameter
% Equivalent noise bandwidth (ENBW) of a kaiser window with length 1024 and
% beta factor of 20 is deemed as a reference ENBW.
refENBW = enbw(kaiser(1024,20));
fs = opts.Fs;
% Get default frequency resolution
dataLen = opts.DataLength;
winLen = signal.internal.rpmtrack.getKaiserWindowLength(dataLen);
% Default frequency resolution (based on pspectrum)
freqResDef1 = 4*fs/1023;
freqResDef2 = refENBW*fs/winLen;
freqResDef = max(freqResDef1,freqResDef2);

% Maximum frequency resolution 
freqResMax = min(2*freqResDef,refENBW*fs);
if (dataLen >= 1e5)
    freqResMax = min(4*freqResDef,refENBW*fs);
end
% Minimum frequency resolution must be chosen such that the time vector
% returns by pspectrum has at least two elements.
alpha = 1/(2*refENBW-1);
freqResMin = fs*refENBW*(1+alpha)/(dataLen-2-alpha);
% Make sure that the maximum frequency resolution is actually larger than
% the minimum value, if it is not, increase it by a factor of 2 till it
% becomes larger.
while (floor(freqResMax/freqResMin) <= 1)
    freqResMax = min(2*freqResMax,refENBW*fs);
end

if ~isfield(opts, 'FrequencyResolution') || isempty(opts.FrequencyResolution)
    winLen = ceil(refENBW*fs/freqResDef);   
    opts.FrequencyResolution = freqResDef;
else
    freqRes = opts.FrequencyResolution;
    % Validate FrequencyResolution
    validateattributes(freqRes,{'numeric'},...
        {'real','positive','finite','nonnan','nonempty','scalar'},...
        'rpmtrack','''FrequencyResolution'' value');
    if ((freqRes < freqResMin) ||...
            (freqRes > freqResMax))
        error(message('signal:rpmtrack:FrequencyResolutionNotAchievable',...
            num2str(freqResMin),num2str(freqResMax)));
    end
    opts.FrequencyResolution = double(freqRes);
	winLen = ceil(refENBW*fs/freqRes);   
end
opts.Window = kaiser(winLen,20);
opts.MinFrequencyResolution = freqResMin;
opts.MaxFrequencyResolution = freqResMax;
opts.ReferenceEquivalentNoiseBandwidth = refENBW;

end