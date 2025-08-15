function Fs = computeFs(TimeInfo,funcName)
%COMPUTEFS convert Ts, Fs, Tv to Fs for signal case.
% For spectrum case, it is not needed. If the Tv is non-uniform, Fs would
% be the median one which is consistent with PSPECTRUM.

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen 

if coder.target('MATLAB')
    validateattributes(TimeInfo, {'single','double','duration','datetime'},...
        {'nonempty','real','vector'},funcName, getString(message('signal:utilities:utilities:strTimeInfo')));
else
    validateattributes(TimeInfo, {'single','double','duration','datetime'},...
        {'nonempty','real','vector'},funcName, 'Time Information');  
end

if isa(TimeInfo, 'single')||isa(TimeInfo, 'double')
    tvec = TimeInfo;
    
    if isscalar(tvec)
        % Fs
        validateattributes(tvec, {'single','double'},...
            {'nonnan','finite','positive'},funcName,'Fs');
        Fs = tvec;
    else
        % numeric Tv in unit of sec
        validateattributes(tvec, {'single','double'},...
            {'nonnan','finite','increasing'},funcName,'Tv');
        Fs = signal.internal.utilities.getEffectiveFs(tvec);
    end
elseif isduration(TimeInfo)
    tvec = seconds(TimeInfo);
    if isscalar(tvec)
        % Ts
        validateattributes(tvec, {'single','double'},...
            {'nonnan','finite','positive'},funcName,'Ts');
        Fs = 1/tvec;
    else
        % Tv in duration
        validateattributes(tvec, {'single','double'},...
            {'nonnan','finite','increasing'},funcName,'Tv');
        Fs = signal.internal.utilities.getEffectiveFs(tvec);
    end
else
    % Tv in datetime
    if length(TimeInfo) < 2
         error(message('signal:utilities:utilities:insufficientDatetimeLength', 1));
    end
    TimeInfo = TimeInfo-TimeInfo(1);
    tvec = seconds(TimeInfo);
    validateattributes(tvec, {'single','double'},...
        {'nonnan','finite','increasing'},funcName,'Tv');
    Fs = signal.internal.utilities.getEffectiveFs(tvec);
end
end


