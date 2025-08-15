function varargout = pkurtosis(x, varargin)
%pkurtosis Spectral kurtosis from signal or spectrogram
%   SK = pkurtosis(X) returns the Spectral Kurtosis as a vector SK given a
%   signal in vector X. Since no time information is given, normalized
%   frequency is assumed. PSPECTRUM with default window size (time
%   resolution in samples), and 80% overlapping is used to compute the
%   spectrogram of X.
%
%   SK = pkurtosis(XT) returns the Spectral Kurtosis as a vector SK given a
%   signal in timetable XT. Timetable XT must contain increasing, and
%   finite time values. PSPECTRUM with default window size (time resolution
%   in samples), and 80% overlapping is used to compute the spectrogram of
%   X.
%
%   SK = pkurtosis(X, Fs) specifies the sample frequency of X in
%   units of hertz in Fs as a numeric scalar. This parameter provides time
%   information to the input and only applies when X is a numeric vector.
%   If Fs is specified as empty, normalized frequency is used. PSPECTRUM
%   with default window size (time resolution in samples), and 80%
%   overlapping is used to compute the spectrogram of X.
%
%   SK = pkurtosis(X, Ts) specifies the sample time of X in Ts as a
%   duration scalar. This parameter provides time information to the input
%   and only applies when X is a numeric vector. If Ts is specified as
%   empty, normalized frequency is used. PSPECTRUM with default window size
%   (time resolution in samples), and 80% overlapping is used to compute
%   the spectrogram of X.
%
%   SK = pkurtosis(X, Tv) specifies time values, Tv, of X as a
%   numeric vector in seconds, or a duration array, or a datetime array.
%   Time values must be increasing, and finite. This parameter provides
%   time information to the input and only applies when X is a numeric
%   vector. If Tv is specified as empty, normalized frequency is used.
%   PSPECTRUM with default window size (time resolution in samples), and
%   80% overlapping is used to compute the spectrogram of X.
%
%   SK = pkurtosis(XT, WINDOW) specifies the window size (time
%   resolution in samples) for PSPECTRUM to compute the spectrogram, when
%   XT is timetable. 80% overlap is used in spectrogram computation.
%   
%   SK = pkurtosis(X, WINDOW) specifies the window size (time
%   resolution in samples) for PSPECTRUM to compute the spectrogram, when X
%   is numeric vector. 80% overlap is used in spectrogram computation.
%   Normalized frequency is assumed.
%
%   SK = pkurtosis(X, T, WINDOW) specifies the window size (time resolution
%   in samples) for PSPECTRUM to compute the spectrogram, when X is numeric
%   vector. The second input argument T contains the time information of X.
%   It can be the sampling frequency Fs as a numeric scalar, the sampling
%   time Ts as a duration scalar, or the time values Tv as a numeric vector
%   or a duration/datetime array. 80% overlap is used in spectrogram
%   computation.
%
%   SK = pkurtosis(S, Fs, F, WINDOW) returns the Spectral Kurtosis
%   given the spectrogram S as a matrix, sampling frequency of the original
%   signal Fs in Hz as a numeric scalar, corresponding frequency vector F
%   as a numeric vector, and the window size (time resolution in samples)
%   WINDOW as a numeric scalar. If S is complex, then S is treated as
%   Short-Time-Fourier-Transform (STFT) of the original signal
%   (spectrogram). If S is real, then S is treated as the square of the
%   absolute values of STFT of the original signal (power spectrogram),
%   thus every element of S must be non-negative. All of the four arguments
%   are required. If Fs is specified as empty, normalized frequency is
%   used.
%
%   SK = pkurtosis(S, Ts, F, WINDOW) specifies the sampling time Ts
%   of the original signal as a duration scalar. If Ts is specified as
%   empty, normalized frequency is used.
%
%   SK = pkurtosis(S, Tv, F, WINDOW) specifies time values, Tv, of
%   the original signal as a numeric vector in seconds, or a duration
%   array, or a datetime array. Time values must be increasing and finite.
%   If Tv is specified as empty, normalized frequency is used.
%
%   [SK,F,THRESH] = pkurtosis(...) returns the corresponding
%   frequency vector F and the threshold THRESH as a numeric scalar.
%
%   [...] = pkurtosis(...,'ConfidenceLevel', P) computes the
%   threshold based on confidence level ranged P ranged from 0 to 1 to
%   detect non-stationarity or non-Gaussianity of the signal. If the SK is
%   beyond the +/- threshold, the signal will have probability of 1-P being
%   stationary Gaussian process. By default, confidence level P = 0.95.
%
%   pkurtosis(...) with no output arguments plots the Spectral
%   Kurtosis and corresponding thresholds in current figure.
%
%
%   EXAMPLE 1: Spectral Kurtosis of a chirp signal with white noise
%   fs = 1000;
%   t = 0:1/fs:10;
%   f1 = 300;
%   f2 = 400; 
%   x = chirp(t,f1,10,f2);
%   x = x + randn(1, length(t));
%   pkurtosis(x, fs)
%   xt = timetable(seconds(t'), x');
%   pkurtosis(xt)
%
%   EXAMPLE 2: Choose optimal window size using kurtogram
%   fs = 1000;
%   t = 0:1/fs:10;
%   f1 = 300;
%   f2 = 400; 
%   x = chirp(t,f1,10,f2);
%   x = x + randn(1, length(t));
%   [kgram, f, w, f0, w0, BW] = kurtogram(x, fs);
%   pkurtosis(x, fs, w0)
%
%   EXAMPLE 3: Compute Spectral Kurtosis given a spectrogram
%   fs = 1000;
%   t = 0:1/fs:10;
%   f1 = 300;
%   f2 = 400; 
%   x = chirp(t,f1,10,f2);
%   x = x + randn(1, length(t));
%   window = 256;
%   overlap = round(window*0.8);
%   nfft = 2*window;
%   [S, F, T] = spectrogram(x, window, overlap, nfft, fs);
%   pkurtosis(S, fs, F, window);
%
%   See also SPECTROGRAM, PSPECTRUM, KURTOGRAM.

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

narginchk(1,6);
nargoutchk(0,5);

isTT = false;
if isa(x, 'timetable')
    isTT = true;
    if nargin > 4
        error(message('signal:pkurtosis:tooManyInputArgNumTimetable', '1')); 
    end
    if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform'))...
            && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
        error(message('signal:pkurtosis:timeTableMustBeHomogeneous'));
    end
    isSingle = isa(x{:,:}, 'single');
else
    isSingle = isa(x, 'single');
end

isMatlab = coder.target('MATLAB');
coder.internal.errorIf(~isMatlab && isTT, 'signal:pkurtosis:TimeTableNotSupported');

[P, fs, f, window, confidenceLevel, normFreq] = parseAndValidateInputs(x, varargin{:});

[SK, threshold] = signal.internal.skurtosis.computeSpectralKurtosis(P, fs, f, window, confidenceLevel);

if isSingle
    SK = single(SK);
    f = single(f);
    threshold = single(threshold);
else
    SK = double(SK);
    f = double(f);
    threshold = double(threshold);
end

if nargout == 0
    coder.internal.errorIf(~isMatlab, 'signal:pkurtosis:PlottingNotSupported');
    signal.internal.skurtosis.skurtosisPlot(SK, fs, f, threshold, confidenceLevel, normFreq);
end

if nargout > 0
    varargout{1} = SK;
end

if nargout > 1
    varargout{2} = f;
end

if nargout > 2
    varargout{3} = threshold;    
    varargout{4} = P;
    varargout{5} = f;    
end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [P, fs, f, window, confidenceLevel, normFreq] = parseAndValidateInputs(x, varargin)
funcName = 'pkurtosis';

if length(varargin) > 2 && isnumeric(varargin{2}) && isnumeric(varargin{3})
    % input is a spectrogram
    isSignal = false;
    normFreq = false;
    
    % Parse and validate x
    validateattributes(x, {'single','double'}, {'nonnan', 'finite', '2d'}, funcName, 'S');
    if isreal(x)
        validateattributes(x, {'single','double'}, {'nonnegative'}, funcName, 'S');
        P = x;
    else
        P = abs(x).^2;
    end
    
    % Parse and validate fs
    if isempty(varargin{1})
        fs = 2*pi;
        normFreq = true;
    else
        fs = signal.internal.utilities.computeFs(varargin{1}, funcName);
    end
    
    % Parse and validate f
    f = varargin{2};
    validateattributes(f, {'single', 'double'}, ...
        {'nonnan', 'finite', 'real', 'vector', ...
        'numel', size(P, 1), '>=', 0, '<=', fs/2}, funcName, 'F');
    f = f(:);
    
    window = varargin{3};
    
    restVarargin = {varargin{4:end}};    
else
    % input is a signal
    isSignal = true;
    [xvec, ~, ~, fs, normFreq, restVararginIdx] = signal.internal.utilities.parseAndValidateSignalTimeInfo(...
        funcName, 'X',  {'singlechannel'}, x, varargin{:});
    restVararginInterm = {varargin{restVararginIdx}};
    if isempty(restVararginInterm) || isstring(restVararginInterm{1}) || ischar(restVararginInterm{1})
        window = getAutoWindow(length(xvec));
        restVarargin = restVararginInterm;
    else
        window = restVararginInterm{1};
        restVarargin = {restVararginInterm{2:end}};
    end
    
end
validateattributes(window, {'single', 'double'}, ...
        {'scalar','nonnan', 'finite', 'positive', 'integer'}, ...
        funcName, 'WINDOW');

% Parse the rest varargin confidencelevel n-v pair
params = struct('ConfidenceLevel', uint32(0));
poptions = struct( ...
    'CaseSensitivity',false, ...
    'PartialMatching','unique', ...
    'StructExpand',false, ...
    'IgnoreNulls',true);
pstruct = coder.internal.parseParameterInputs(params, poptions, restVarargin{:});
confidenceLevel = coder.internal.getParameterValue(pstruct.ConfidenceLevel, 0.95, restVarargin{:});
validateattributes(confidenceLevel, {'single','double'}, ...
     {'nonnan', 'positive', 'scalar', '<', 1}, funcName, 'ConfidenceLevel');

 if isSignal
     coder.ignoreCatch
     try %#ok<EMTC>
         [P, f] = pspectrum(xvec, fs, 'spectrogram', ...
             'FrequencyResolution', fs/window, 'OverlapPercent', 80);
     catch ME
         % This parsing pattern might be changed if pspectrum error message
         % is changed
         if (strcmp(ME.identifier, 'signal:pspectrum:FreqResNotAchivable'))
             fres = regexp(ME.message, '\[([0-9.]+),\s*([0-9.]+)\]', 'tokens');
             freslb = str2double(fres{:}{1});
             fresub = str2double(fres{:}{2});
             wub = floor(fs/freslb);
             wlb = ceil(fs/fresub);
             error(message('signal:pkurtosis:invalidWindowSize', window, wlb, wub));
         else
             throw(ME);
         end
     end     
 end
 
end

% See \matlab\toolbox\signal\signalanalyzer\src\heatmap\include\Spectrogram.hpp
% static size_t calculateTimeResolutionSamples(size_t numberOfSignalSamples)
function w = getAutoWindow(lenx)
if lenx >= 16384
    w = ceil(lenx/128);
elseif lenx >= 8192
    w = ceil(lenx/64);
elseif lenx >= 4096
    w = ceil(lenx/32);
elseif lenx >= 2048
    w = ceil(lenx/16);
elseif lenx >= 64
    w = ceil(lenx/8);
else
    w = ceil(lenx/2);
end
end

