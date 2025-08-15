function varargout = kurtogram(x, varargin)
%KURTOGRAM Kurtogram to visualize spectral kurtosis with multi window sizes
%   KGRAM = KURTOGRAM(X) returns the fast kurtogram matrix KGRAM given a
%   "single-channel" signal X. X can be a vector or a timetable with single
%   variable of single column. If X is a vector, normalized frequency is
%   assumed. If X is timetable, it must contain increasing, and finite time
%   values. The default level used in kurtogram computation is max(0,
%   floor(log2(size(X, 1)) - 6)).
%   
%   KGRAM = KURTOGRAM(X, Fs) specifies Fs as a positive numeric scalar
%   corresponding to the sample rate of X in units of hertz. This parameter
%   provides time information to the input and only applies when X is a
%   vector. If Fs is specified as empty, normalized frequency
%   is used. The default level used in kurtogram computation is max(0,
%   floor(log2(size(X, 1)) - 6)).
%
%   KGRAM = KURTOGRAM(X, Ts) specifies Ts as a positive scalar duration
%   corresponding to the sample time of X. This parameter provides time
%   information to the input and only applies when X is a vector. If Ts is
%   specified as empty, normalized frequency is used. The default level
%   used in kurtogram computation is max(0, floor(log2(size(X, 1)) - 6)).
%
%   KGRAM = KURTOGRAM(X, Tv) specifies time values, Tv, of X as a numeric
%   vector in seconds, a duration vector, or a datetime vector. Time values
%   must be increasing, and finite. This parameter provides time
%   information to the input and only applies when X is a vector. If Tv is
%   specified as empty, normalized frequency is used. The default level
%   used in kurtogram computation is max(0, floor(log2(size(X, 1)) - 6)).
%
%   KGRAM = KURTOGRAM(..., LEVEL) specifies the level of the fast kurtogram
%   in positive integer LEVEL. When X is a timetable, LEVEL is the 2nd
%   input argument. When X is a vector, LEVEL is the 3rd input argument.
%
%   The fast kurtogram matrix KGRAM has 2*LEVEL rows and 3*2^LEVEL columns
%   (If LEVEL=0, KGRAM has 1 row and 3 columns). Each row of the matrix
%   represents a spectral kurtosis vector with level 0, 1, log2(3), 2,
%   1+log2(3), 3, 2+log2(3),..., LEVEL. For a certain level n, the
%   equivalent window size is 2^(n+1).
%
%   [KGRAM, F, W, FC, WC, BW] = KURTOGRAM(...) returns
%       F:  the associated frequency vector. The length of F is the same as
%           the number of columns of KGRAM.
%       W:  the associated window size vector. The length of W is the same
%           as the number of rows of KGRAM.
%       FC: the frequency where the maximal spectral kurtosis is located.
%           It is also the suggested central frequency for the optimal
%           bandpass filter to maximize the kurtosis of the envelope of the
%           filtered signal.
%       WC: the window size where the maximal spectral kurtosis on the
%           kurtogram is located.
%       BW: the suggested bandwidth for the optimal bandpass filter.
%
%   KURTOGRAM(...) with no output argument, plots the kurtogram with
%   frequency as x axis, level k and equivalent window length as y axis.
%   List the maximal spectral kurtosis, optimal window length, suggested
%   central frequency and bandwidth for bandpass filtering in the title of
%   the plot.
%   
%   EXAMPLE 1: Compute kurtogram given a signal
%   x = randn(5000,1);
%   kurtogram(x)
%
%   EXAMPLE 2: Compute kurtogram given a timetable   
%   xt = timetable(seconds(1:5000)', randn(5000,1));
%   kurtogram(xt)
%
%   EXAMPLE 3: Compute kurtogram with specified level
%   x = randn(5000,1);
%   fs = 1;
%   level = 5;
%   kurtogram(x, fs, level);
%   
%   EXAMPLE 4: Find the frequency band of the non-stationary component using kurtogram
%   fs = 1000;
%   t = 0:1/fs:10;
%   x = randn(1, length(t));
%   f0 = 200; 
%   x(t>5) = x(t>5) + 5*sin(2*pi*f0*t(t>5));  % add non-stationary component
%   figure; plot(t, x)
%   figure; kurtogram(x, fs)
%
%   See also pkurtosis

%   Copyright 2017-2020 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen
narginchk(1, 3);
if isa(x, 'timetable')
    if nargin > 2
        error(message('signal:kurtogram:tooManyInputArgNumTimetable', '1')); 
    end
end
nargoutchk(0, 6);
if ~coder.target('MATLAB')
    if nargout == 0
        % Plotting is not supported for code generation. If this is running in
        % MATLAB, just call MATLAB's KURTOGRAM, else error.
        coder.internal.assert(coder.target('MEX') || coder.target('Sfun'), ...
            'signal:codegeneration:PlottingNotSupported');
        feval('kurtogram',x,varargin{:});
        return
    end
end

[x, fs, level, normFreq] = parseAndValidateInputs(x, varargin{:});
[kgram, f, w, L, fc, wc, BW, maxNode] = signal.internal.skurtosis.computeKurtogram(x, fs, level);

if nargout == 0
    signal.internal.skurtosis.kurtogramPlot(kgram, maxNode, fs, f, w, L, fc, wc, BW, normFreq);
end

% Collect outputs and return them
if nargout > 0
    varargout{1} = kgram;
end

if nargout > 1
    varargout{2} = f;
end

if nargout > 2
    varargout{3} = w;
end

if nargout > 3
   varargout{4} = fc;
end

if nargout > 4
    varargout{5} = wc;
end

if nargout > 5
    varargout{6} = BW;
end
end

function [xvec, fs, level, normFreq] = parseAndValidateInputs(x, varargin)
funcName = 'kurtogram';
varName = 'X';
attributes = {'singlechannel'};

[xvecTmp, ~, ~, fs, normFreq, restVararginIdx] = signal.internal.utilities.parseAndValidateSignalTimeInfo(...
    funcName, varName, attributes, x, varargin{:});
restVarargin = {varargin{restVararginIdx}};
xvec = xvecTmp(:);  % Kurtogram computation engine only support column vector

if isempty(restVarargin)
    level = -1;
else
    level = restVarargin{1};
    validateattributes(level,{'single', 'double'},...
        {'nonnan', 'finite','nonnegative','scalar','integer'},...
        funcName,'LEVEL');
end
end


% LocalWords:  KGRAM Fs Tv nd FC BW xt fs pkurtosis Sfun singlechannel
