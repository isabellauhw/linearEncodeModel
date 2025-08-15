function varargout = pentropy(x, varargin)
%pentropy Spectral entropy from signal or spectrum
%   SE = pentropy(XT) returns a time series of spectral entropy in
%   timetable SE given a timetable XT. The timetable XT must have single
%   variable with single column. The function uses the default options of
%   PSPECTRUM to compute the power spectrogram.
%
%   SE = pentropy(X, Fs) returns a sequence of spectral entropy in vector
%   SE given a numeric vector X and its sampling frequency in Hertz in
%   numeric scalar Fs. The function uses the default options of PSPECTRUM
%   to compute the power spectrogram.
%
%   SE = pentropy(X, Ts) specifies the sample time of X in Ts as a duration
%   scalar. This parameter provides time information to the input X, and
%   only applies when X is a numeric vector. The function uses the default
%   options of PSPECTRUM to compute the power spectrogram.
%
%   SE = pentropy(X, Tv) specifies time values, Tv, of X as a numeric
%   vector in seconds, or a duration array, or a datetime array. Time
%   values must be increasing and finite. This parameter provides time
%   information to the input X, and only applies when X is a numeric
%   vector. The function uses the default options of PSPECTRUM to compute
%   the power spectrogram.
%
%   SE = pentropy(P, F, Tv) returns a sequence of spectral entropy SE given
%   a power spectrum or a power spectrogram P, the corresponding frequency
%   vector F in Hertz, and the corresponding time values Tv. P is a
%   non-negative matrix, where the element at i th row and j th column
%   represent the power of the signal at i th frequency bin centered at
%   F(i) and j th time instance Tv(j). F specifies the corresponding
%   frequencies in Hertz as a numeric vector. The length of F equals the
%   number of rows of P. Tv specifies the time values as a numeric vector
%   in seconds, or a duration array, or a datetime array. The length of Tv
%   equals the number of columns of P. Output SE is a numeric vector with
%   length equal to the number of columns of P.
%
%   SE = pentropy(P, F, Ts) specifies sample time Ts of the power
%   spectrogram P as a duration scalar. This parameter provides time
%   information to the input P, and only applies when P is a matrix with at
%   least 2 columns.
%
%   [...] = pentropy(..., 'Name1', Value1, 'Name2', Value2, ...) specifies
%   additional properties as name-value pairs. The supported Name-Value
%   pairs are:
%
%       'Instantaneous':   specifies whether to compute the instantaneous
%                          spectral entropy as a time series or compute the
%                          spectral entropy value of the whole signal or
%                          spectrum as a scalar. By default the value is
%                          set to true.
%
%       'Scaled':          specifies whether scale the spectral entropy by
%                          the spectral entropy of corresponding white
%                          noise or not. By default, the value is set to
%                          true.
%
%       'FrequencyLimits': specifies frequency range in Hertz for computing
%                          spectral entropy. By default, the frequency
%                          range is set to [0, Fs/2], where Fs is the
%                          sampling frequency of the signal.
%
%       'TimeLimits':      specifies time range for computing spectral
%                          entropy. If the input time information is
%                          numeric or duration, the time range value [T1,
%                          T2] can be numeric or duration. If the input
%                          time information is in datetime, [T1, T2] can be
%                          numeric, duration or datetime. The numeric T1
%                          and T2 is in seconds. By default, the time range
%                          is the entire time span of the signal or
%                          spectrum.
%
%   [SE, T] = pentropy(...) returns the time vector T corresponding to the
%   sequence of spectral entropy SE. If the input argument is a timetable
%   XT, then T is the same as SE.Time. For other cases, T has the same data
%   type of the input time information (Fs/Ts/Tv). The output T only
%   applies when 'Instantaneous' is true.
%
%   pentropy(...) without output argument, if 'Instantaneous' is true, the
%   function will plot the spectral entropy with time. Otherwise, the
%   function will output the spectral entropy value as a scalar.
%
%   See also PSPECTRUM, PWELCH, SPECTROGRAM
%
%   % EXAMPLE 1: 
%      % Compute spectral entropy given a timetable
%      XT = timetable(seconds(1:100)', randn(100,1));
%      SE = pentropy(XT);
%
%   % EXAMPLE 2: 
%      % Compute spectral entropy given a vector signal
%      X = randn(1000, 1);
%      Fs = 1;
%      [SE, T] = pentropy(X, Fs);
%
%   % EXAMPLE 3: 
%      % Compute spectral entropy given a power spectral density
%      X = randn(1000, 1);
%      window = 100;
%      noverlap = 80;
%      nfft = 200;
%      Fs = 1;
%      [P, F] = pwelch(X, window, noverlap, nfft, Fs);
%      T = 1;
%      SE = pentropy(P, F, T);
%
%      X = randn(1000, 1);
%      [P, F] = pspectrum(X);
%      T = 1;
%      SE = pentropy(P, F, T);
%
%   % EXAMPLE 4: 
%      % Compute the spectral entropy given a spectrogram
%      X = randn(1000, 1);
%      window = 100;
%      noverlap = 80;
%      nfft = 200;
%      Fs = 1;
%      [~, F, T, P] = spectrogram(X, window, noverlap, nfft, Fs);
%      SE = pentropy(P, F, T);
%
%      X = randn(1000, 1);
%      [P, F, T] = pspectrum(X, 'spectrogram');
%      SE = pentropy(P, F, T);
%
%   % EXAMPLE 5:
%      % Compute the non-scaled and non-instantaneous spectral
%      % entropy with specified time and frequency limits
%      X = randn(1000, 1);
%      Ts = seconds(1);
%      SE = pentropy(X, Ts, 'Instantaneous', false, 'Scaled', false, ...
%                 'TimeLimits', [200 500], 'FrequencyLimits', [0.1 0.3]);
%
%   % EXAMPLE 6:
%      % Use spectral entropy to detect start and end point of
%      % a sine wave in white noise
%      Fs = 100;
%      t = 0:1/Fs:10;
%      sin_wave = 2*sin(2*pi*20*t') + randn(length(t),1);
%      x = [randn(1000,1); sin_wave; randn(1000,1)];
%      pentropy(x, Fs)

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen

narginchk(1, 11);
nargoutchk(0, 2);


isTT = isa(x, 'timetable');
if isTT
    if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform'))...
            && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
        error(message('signal:pentropy:timeTableMustBeHomogeneous'));
    end
    isSingle = isa(x{:,:}, 'single');
else
    isSingle = isa(x, 'single');
end

isMatlab = coder.target('MATLAB');

coder.internal.errorIf(~isMatlab && isTT, ...
    'signal:pentropy:TimeTableNotSupported');


[S, T, scaled, instant] = parseAndValidateInputs(x, nargout, varargin{:});

if instant
    SS = sum(S,1);
    P = S;
    for i = 1:size(S,2)
        P(:,i) = P(:,i) ./ SS(i);
    end
else
    P = sum(S, 2)./sum(S(:));
end

SE = sum(-P.*log2(P), 1);

if scaled
    SE = SE./log2(size(P,1));
end

SE = SE(:);

if isSingle
    if isa(T, 'double')
        Tout = single(T);
    else
        Tout = T;
    end
else
    if isa(T, 'single')
        Tout = double(T);
    else
        Tout = T;
    end
end


coder.internal.errorIf(~isMatlab && nargout == 0 && instant, 'signal:pentropy:PlottingNotSupported');

if nargout == 0
    if instant
        signal.internal.pentropy.pentropyPlot(Tout, SE);
    else
        varargout{1} = SE;
    end
end

if nargout > 0
    if instant && isTT
        SEtt = timetable(Tout, SE);
        SEtt.Properties.DimensionNames{1} = x.Properties.DimensionNames{1};
        varargout{1} = SEtt;
    else
        varargout{1} = SE;
    end
end

if nargout > 1
    varargout{2} = Tout;
end
end

%%
function [S, T, scaled, instant] = parseAndValidateInputs(x, numArgOut, varargin)
funcName = 'pentropy';

% Find the location of first string, if no string input, the index is
% length of varargin + 1
lenArg = length(varargin);
strIdx = lenArg + 1;
for argIdx = 1:lenArg
    if ischar(varargin{argIdx}) || isStringScalar(varargin{argIdx})
        strIdx = argIdx;
        break
    end
end

% Determine whether input is a signal
isSignal = (strIdx<=2);

%Parse and validate inputs
params = struct( ...
    'FrequencyLimits', uint32(0), ...
    'TimeLimits', uint32(0), ...
    'Scaled', uint32(0), ...
    'Instantaneous', uint32(0));
poptions = struct( ...
    'CaseSensitivity',false, ...
    'PartialMatching','unique', ...
    'StructExpand',false, ...
    'IgnoreNulls',true);


if isSignal
    [xval, ~, timeInfo, Fs, ~, restVarargin, Traw] = signal.internal.utilities.parseAndValidateSignalTimeInfo(...
        funcName, 'X', {'singlechannel'}, x, varargin{:});
else
    [Sraw, ~, timeInfo, restVarargin, Traw] = signal.internal.utilities.parseAndValidateSpectrumTimeInfo(...
        funcName, 'P', {}, x, varargin{2:end});
    
    restVarargin = restVarargin + 1;
    F = varargin{1};
    validateattributes(F, {'single','double'}, ...
        {'nonempty','nonnan','finite','nonnegative','increasing','vector','numel',size(Sraw,1)},...
        funcName, 'F');
end

coder.internal.errorIf(isempty(timeInfo), 'signal:pentropy:timeInfoNotProvided', 2);

pstruct = coder.internal.parseParameterInputs(params, poptions, varargin{restVarargin});

if isSignal    
    FRange = coder.internal.getParameterValue(pstruct.FrequencyLimits, [0 Fs/2], varargin{restVarargin});    
    validateattributes(FRange, {'single','double'}, ...
        {'nonnan','vector','real','nondecreasing','numel',2,'>=',0,'<=',Fs/2});
else
    FRange = coder.internal.getParameterValue(pstruct.FrequencyLimits, [F(1) F(end)], varargin{restVarargin});   
    validateattributes(FRange, {'single','double'}, ...
        {'nonnan','vector','real','nondecreasing','numel',2,'>=',F(1),'<=',F(end)});
end

TRange = coder.internal.getParameterValue(pstruct.TimeLimits, [Traw(1), Traw(end)], varargin{restVarargin});
scaled = coder.internal.getParameterValue(pstruct.Scaled, true, varargin{restVarargin});
instant = coder.internal.getParameterValue(pstruct.Instantaneous, true, varargin{restVarargin});

validateattributes(scaled, {'numeric','logical'}, {}, 'pentropy', 'scaled');
validateattributes(instant, {'numeric','logical'}, {}, 'pentropy', 'instant');

coder.internal.errorIf(instant~=0 && instant~=1, 'signal:pentropy:invalidLogicalValue', 'Instantaneous', '0/1/true/false');   
coder.internal.errorIf(scaled~=0 && scaled~=1, 'signal:pentropy:invalidLogicalValue', 'Scaled', '0/1/true/false');
coder.internal.errorIf(~instant && numArgOut > 1, 'signal:pentropy:tooManyOutputArgument', 1, 'Instantaneous', 'false');

% Validate Time Range
TVecRange = signal.internal.utilities.validateTimeRange(TRange, [Traw(1), Traw(end)], funcName);

% Compute power spectrogram if input is a signal
if isSignal   
    [Sraw, F, Tspec] = pspectrum(xval, timeInfo, 'spectrogram');
    Tspec = Tspec(:); %%% need to be addressed correctly        
else
    Tspec = Traw(:);
end

% Find the actual row/column index to cut Sraw
if isa(Tspec, 'duration')
    TVec = seconds(Tspec);
elseif isa(Tspec, 'datetime')
    TVec = seconds(Tspec-Tspec(1));
else
    TVec = Tspec;
end

[Tmin, Tmax] = signal.internal.utilities.getEffectiveRangeIdx(TVec, TVecRange);
[Fmin, Fmax] = signal.internal.utilities.getEffectiveRangeIdx(F, FRange);

S = Sraw(Fmin(1):Fmax(1), Tmin(1):Tmax(1));
T = Tspec(Tmin(1):Tmax(1));
end

