function [P, tvec, timeInfo, restVarargin, td] = parseAndValidateSpectrumTimeInfo(...
    funcName, varName, attributes, P, varargin)
%PARSEANDVALIDATESPECTRUMTIMEINFO helper function to parse the following pattern
%   fun(P)     - P is power spectrum/spectrogram, a nonnegative double
%                vector/matrix. Without the time information, time unit is
%                sample.
%   fun(P, Ts) - P must have at least 2 columns, Ts is sampling interval
%                for the spectrogram P ((differs from the Ts of the signal
%                X), duration scalar
%   fun(P, Tv) - Tv is the corresponding time values,
%                double/duration/datetime vector/scalar. Note: when P is a
%                single column (power spectrum), Tv represents a single
%                time stamp of that power spectrum.
%
%   Inputs:
%   funcName   - function name string for error message
%   varName    - input variable name
%   attributes - attributes to check, it can be {'regular'}
%   x          - the time signal or the spectrum
%   varargin   - if it is not empty, then timeInfo = varargin{1}
%
%   Outputs:
%   xval       - values of signal or spectrum
%   tvec       - time vector for the signal or spectrum. If varargin is
%                empty or the first argument of varargin is empty, and x is
%                not a timetable, then normalized frequency is used, tvec
%                is a vector with unit of "Samples". In other cases, tvec
%                is a vector in seconds.
%   timeInfo   - the raw time information provided by varargin.
%   restVarargin - indices of the rest of varargin input arguments after time information.
%   td         - duration/datetime array if tvec is in seconds. Same as
%                tvec, when tvec is in "Samples".

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen

outputTd = (nargout>=5);

% General check on P
validateattributes(P, {'single', 'double'}, ...
    {'nonempty','real','finite','2d','nonnegative'}, funcName, varName);

len = size(P, 2);

if ~isempty(varargin) && (isa(varargin{1}, 'single') || isa(varargin{1}, 'double') ...
        || isa(varargin{1}, 'duration') || isa(varargin{1}, 'datetime'))
    timeInfo = varargin{1};    
    restVarargin = 2:numel(varargin);
else
    timeInfo = [];    
    restVarargin = 1:numel(varargin);
end

if coder.target('MATLAB')
    validateattributes(timeInfo, {'double','single','duration','datetime'}, ...
        {'nonempty','vector'}, funcName, 'Ts/Tv');
else
    validateattributes(timeInfo, {'double','single'}, ...
        {'nonempty','vector'}, funcName, 'Ts/Tv');
end

switch class(timeInfo)
    case {'double','single','datetime'}
        if isempty(timeInfo)
            timeType = 'normalized';
        else
            timeType = 'Tv';
        end
    case 'duration'
        if isscalar(timeInfo) && len > 1
            timeType = 'Ts';
        else
            timeType = 'Tv';
        end
end

isTimeInfoSingle = isa(timeInfo, 'single');

if coder.target('MATLAB')
    tvec = [];
    td = [];
else
    if isTimeInfoSingle
        tvec = zeros(1,len,'like', single(0));
        td = zeros(1,len,'like', single(0));
    else
        tvec = zeros(1,len,'like', 0);
        td = zeros(1,len,'like', 0);
    end  
end

switch timeType
    case 'normalized'
        if isTimeInfoSingle
            tvec = single((0:len-1).');
        else
            tvec = (0:len-1).';
        end
        if outputTd
            td = tvec;
        end
    case 'Ts'
        if coder.target('MATLAB')
            Ts = seconds(timeInfo);
            validateattributes(Ts, {'single','double'}, ...
                {'nonnan','finite','real','positive'}, funcName, 'Ts');
            tvec = (0:len-1).'*Ts;
            if outputTd
                td = (0:len-1).'*timeInfo;
            end
        end
    case 'Tv'
        Tv = timeInfo(:);
        if outputTd
            td = Tv;
        end
        if isa(Tv, 'duration') && coder.target('MATLAB')
            tvec = seconds(Tv);
        elseif isa(Tv, 'datetime') && coder.target('MATLAB')
            tvec = seconds(Tv - Tv(1));
        else
            tvec = Tv;
        end
        
        validateattributes(tvec, {'single','double'}, ...
            {'nonnan','finite','real','increasing','numel',len}, funcName, 'Tv');
        
        [~, needResampling] = signal.internal.utilities.getEffectiveFs(tvec);
        if needResampling && any(strcmp(attributes, 'regular'))
            coder.internal.error('signal:utilities:utilities:nonUniformTimeVector', 'Tv');
        end
end





