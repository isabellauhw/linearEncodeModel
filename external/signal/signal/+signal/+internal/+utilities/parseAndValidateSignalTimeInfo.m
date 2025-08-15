function [xval, tvec, timeInfo, Fs, normFreq, restVarargin, td] = parseAndValidateSignalTimeInfo(...
    funcName, varName, attributes, x, varargin) 
%PARSEANDVALIDATESIGNALTIMEINFO helper function to parse the following pattern
%   fun(X)     - X is a single-channel/multi-channel signal, a double
%                vector/matrix 
%   fun(XT)    - XT is a timetable
%   fun(X, Fs) - Fs is sampling frequency (Hz), double scalar
%   fun(X, Ts) - Ts is sampling interval, duration scalar
%   fun(X, Tv) - Tv is the corresponding time array,
%                double/duration/datetime array 
%
%   Inputs:
%   funcName   - function name string for error message
%   varName    - input variable name, typically
%   attributes - attributes to check on the signal and time, can be
%                'regular', 'singlechannel'/'multichannel'
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
%   timeInfo   - the raw time information provided by varargin. When x is a
%                timetable, timeInfo = x.Properties.RowTimes
%   Fs         - sampling frequency in Hz
%   normFreq   - flag for normalized frequency. True for normalized
%                frequency
%   restVarargin - Indices of the rest input arguments in varargin after time information.
%   td         - If normalized frequency, td is double/single vector with
%                unit of samples. If time information is Fs, td is
%                double/single vector with unit of seconds. If time
%                information is Ts, td is duration array. If time
%                information is Tv, td is equal to Tv.
%

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen

isInMATLAB = coder.target('MATLAB');

% Decide whether to compute td
outputTd = (nargout>=7);

%--------------------------------------------------------------------------
% General check on x
%--------------------------------------------------------------------------
validateattributes(x, {'single', 'double', 'timetable'}, {'nonempty','2d'}, funcName, varName);
isTT = isa(x, 'timetable');

%--------------------------------------------------------------------------
% Compute and validate the length of the signal x
%--------------------------------------------------------------------------
if ~isTT && isvector(x)
    len = length(x);
else
    len = size(x, 1);
end
  
coder.internal.errorIf(len < 2, 'signal:utilities:utilities:insufficientSignalLength', varName, 1);

%--------------------------------------------------------------------------
% Determine the time type of the input
%--------------------------------------------------------------------------
normFreq = false;    % place holder for normalized frequency flag
if isTT
    if ~all(varfun(@isnumeric,x,'OutputFormat','uniform'))
        error(message('signal:utilities:utilities:ttValuesMustBeNumeric'));
    end
    timeInfo = x.Properties.RowTimes;
    xtemp = x{:,:};
    timeType = 'Tv';    
    restVarargin = 1:numel(varargin);
else
    xtemp = x;
    if ~isempty({varargin{:}}) && (isa(varargin{1}, 'single') || isa(varargin{1}, 'double') ...
            || isa(varargin{1}, 'duration') || isa(varargin{1}, 'datetime'))
        timeInfo = varargin{1};        
        restVarargin = 2:numel(varargin);
    else
        timeInfo = [];        
        restVarargin = 1:numel(varargin);
    end
    
    if ~isempty(timeInfo)
        validateattributes(timeInfo, {'double','single','duration','datetime'}, ...
            {'vector'}, funcName, 'Fs/Ts/Tv');
    end
    
    switch class(timeInfo)
        case {'double', 'single'}
            if isempty(timeInfo)
                timeType = 'normalized';
                normFreq = true;  % the only situation when normFreq = true
            else
                if isscalar(timeInfo)
                    timeType = 'Fs';
                else
                    timeType = 'Tv';
                end
            end
        case 'duration'
            if isscalar(timeInfo)
                timeType = 'Ts';
            else
                timeType = 'Tv';
            end
        case 'datetime'
            timeType = 'Tv';
    end
end

%--------------------------------------------------------------------------
% Parse and validate x values
%--------------------------------------------------------------------------
validateattributes(xtemp,{'single','double'},{'real','nonnan','finite','2d'},funcName,varName);
if any(strcmp(attributes, 'singlechannel'))
    if isTT
        validateattributes(xtemp, {'single','double'}, {'vector'}, funcName, 'timetable variable');        
    else
        validateattributes(xtemp, {'single','double'}, {'vector'}, funcName, varName);        
    end
end

%--------------------------------------------------------------------------
% Parse and validate time information
%--------------------------------------------------------------------------
isSingle = isa(timeInfo, 'single');
if coder.target('MATLAB')
    td = [];
else
    if isSingle
        td = single([]);
    else
        td = [];
    end
end

needResampling = false;
switch timeType
    case 'normalized'
        if isSingle
            Fs = single(2*pi);
        else
            Fs = 2*pi;
        end
        ttemp = (0:len-1).';
        if outputTd
            td = ttemp;
        end
    case 'Fs'
        Fs = timeInfo;   % in Hz
        validateattributes(Fs, {'single','double'}, ...
            {'nonnan','finite','real','positive'}, funcName, 'Fs');
        ttemp = (0:len-1).'/Fs;
        if outputTd
            td = ttemp;
        end
        %--------Need to revisit----------------
    case 'Ts'
        if coder.target('MATLAB')
            Ts = seconds(timeInfo);
            validateattributes(Ts, {'single','double'}, ...
                {'nonnan','finite','real','positive'}, funcName, 'Ts');
            Fs = 1/Ts;
            ttemp = (0:len-1).'*Ts;
            if outputTd
                td = (0:len-1).'*timeInfo;
            end
        else
            Fs = 1;
            ttemp = (0:len-1).'*Fs;
        end
    case 'Tv'
        if isTT
            timeVarName = ...
                [getString(message('signal:utilities:utilities:timeValuesOfTT')) ' ' varName];
        else
            timeVarName = timeType;
        end
        Tv = timeInfo(:);
        if outputTd
            td = Tv;
        end
        if isa(Tv, 'duration')
            ttemp = seconds(Tv);
        elseif isa(Tv, 'datetime')
            ttemp = seconds(Tv - Tv(1));
        else
            ttemp = Tv;
        end
        if coder.target('MATLAB')
            validateattributes(ttemp, {'single','double'}, ...
                {'nonnan', 'finite','real','increasing','numel',len}, funcName, timeVarName);
        else
            validateattributes(ttemp, {'single','double'}, ...
                {'nonnan', 'finite','real','increasing','numel',len}, funcName, 'Tv');
        end
        
        [Fs, needResampling] = signal.internal.utilities.getEffectiveFs(ttemp);
        if needResampling && any(strcmp(attributes, 'regular'))
            if isInMATLAB
                error(message('signal:utilities:utilities:nonUniformTimeVector', timeVarName));
            else
                coder.internal.error('signal:utilities:utilities:nonUniformTimeVector', timeVarName);
            end
        end
    otherwise
        Fs = 1;
        ttemp = (0:len-1).'*Fs;
end

if needResampling
    [xval, tvec] = resample(xtemp, ttemp, Fs, 'linear');
else
    xval = xtemp;
    tvec = ttemp;
end
end

% LocalWords:  XT Fs Tv func singlechannel xval tvec tt
