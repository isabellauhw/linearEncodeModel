function varargout = pwelch(x, varargin)
%PWELCH Power Spectral Density estimate via Welch's method.
%
%   Pxx = PWELCH(X,WINDOW)
%   Pxx = PWELCH(X,WINDOW,...,SPECTRUMTYPE)
%   Pxx = PWELCH(X,WINDOW,NOVERLAP)
%   [Pxx,W] = PWELCH(X,WINDOW,NOVERLAP,NFFT)
%   [Pxx,W] = PWELCH(X,WINDOW,NOVERLAP,W)
%   [Pxx,F] = PWELCH(X,WINDOW,NOVERLAP,NFFT,Fs)
%   [Pxx,F] = PWELCH(X,WINDOW,NOVERLAP,F,Fs)
%   [Pxx,F,Pxxc] = PWELCH(...,'ConfidenceLevel',P)
%   [...] = PWELCH(...,FREQRANGE)
%   [...] = PWELCH(...,TRACE)
%   PWELCH(...)
%
%   Limitations:
%   1. X must not be a tall row vector.
%   2. WINDOW argument must be always specified.
%
%   See also PWELCH, TALL.

%   Copyright 2020 The MathWorks, Inc.

narginchk(1,9);
nargoutchk(0,3);

% Parse all input arguments and validate with in-memory spectrogram.
[x, win, windowLength, options, isOutputSingle, isTypeUnknown, varargin] = iParseArguments(x, varargin{:});

% When nargout == 0, pwelch plots the Welch periodogram. Determine how many
% outputs we need to compute for plotting.
numOutputs = nargout;
if nargout == 0
    % Determine if we need to compute the confidence levels for plotting.
    numOutputs = 2 + ~isnan(options.conflevel);
end

% Compute the periodogram for each segment with
% matlab.tall.blockMovingWindow and capture if the input is single or if it
% is real.
[sxx, isInputReal, isInputSingle] = iDoPeriodogramWithBlockMovingWindow(x, win, windowLength, ...
    options, isOutputSingle, isTypeUnknown, varargin{:});

% Compute the frequency vector for the given freqrange option. If it's the
% default option, we need to know if the input signal is real or complex.
% Also validate the tall size of the input signal, it must have at least
% the number of samples of the window.
import matlab.bigdata.internal.broadcast
sizeXInTallDim = size(x, 1);
f = clientfun(@(varargin) iCreateFrequencyVectorAndValidateTallSize(varargin{:}, options, isOutputSingle, windowLength), ...
    x(1, :), broadcast(isInputSingle), broadcast(isInputReal), broadcast(sizeXInTallDim));

% Compute the resulting periodogram with the given trace option: maxhold,
% minhold, or mean (default).
if options.maxhold || options.minhold
    % Also compute the average periodogram if the user has specified
    % maxhold or minhold. Confidence intervals are always computed around
    % the average periodogram even if the specified trace option was
    % maxhold or minhold. Pxx is reduced to a 1-by-nfft vector or a
    % 1-by-nfft-by-numChannels ND-array.
    [sxx, numSegments, avgSxx] = iComputeAggregatedPeriodogram(sxx, options);
    
    % Compute the power spectral density from the computed periodogram and
    % format pxx, f, and pxxc according to freqrange. They've been computed
    % assuming 'twosided' freqrange. If the default freqrange applies,
    % format to 'onesided' if the input signal is real.
    [varargout{1:numOutputs}] = clientfun(@(varargin) iComputePSDAndConfInterval(options, varargin{:}), ...
        broadcast(isInputReal), broadcast(numSegments), f, sxx, avgSxx);
else % "mean"
    % Compute the resulting average periodogram. Pxx is reduced to a
    % 1-by-nfft vector or a 1-by-nfft-by-numChannels ND-array.
    [sxx, numSegments] = iComputeAggregatedPeriodogram(sxx, options);
    
    % Compute the power spectral density from the computed periodogram and
    % format pxx, f, and pxxc according to freqrange. They've been computed
    % assuming 'twosided' freqrange. If the default freqrange applies,
    % format to 'onesided' if the input signal is real.
    [varargout{1:numOutputs}] = clientfun(@(varargin) iComputePSDAndConfInterval(options, varargin{:}), ...
        broadcast(isInputReal), broadcast(numSegments), f, sxx);
end

% Extract some useful information known upfront to set the output adaptors.
[varargout{1:numOutputs}] = iSetOutputAdaptors(x, win, options.nfft, varargout{:});

% Plot the outputs if no outputs were requested.
if nargout == 0
    iPlotPwelch(windowLength, options, isInputReal, varargout{:});
end
end

%--------------------------------------------------------------------------
function [x, win, windowLength, options, isOutputSingle, isTypeUnknown, varargin] = iParseArguments(x, varargin)
% Parse input argments of tall/pwelch with welchparse and get available
% metadata from the tall input x.

% Only input signal x can be tall
tall.checkIsTall(upper(mfilename), 0, x);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% x must be a tall column vector or a tall matrix
x = tall.validateMatrix(x, 'signal:tall:TallInputMustBeColumnOrMatrix');
x = tall.validateNotRow(x, 'signal:tall:TallInputMustBeColumnOrMatrix');

% x must be a tall double or tall single input
x = tall.validateTypeWithError(x, 'pwelch', 1, {'double', 'single'}, {'MATLAB:pwelch:invalidType', 'x'});

% Check that window has been specified. Check if it is a scalar or vector,
% it cannot be []. Throw the same error as welchparse.
if isempty(varargin)
    error(message('signal:welch:WindowMustBeProvidedForTall'));
end
win = varargin{1};
if ~any(size(win) == 1) || ischar(win)
    error(message('signal:welchparse:MustBeScalarOrVector', 'WINDOW'));
end
if ~isscalar(win)
    % User-defined window
    validateattributes(win, {'double', 'single'}, {'nonsparse'}, 'pwelch', 'Window');
    windowLength = length(win);
else
    % Scalar - window length. Cast to double to ensure precision rules for
    % pwelch. Create default window.
    windowLength = double(win);
    win = hamming(windowLength);
end

[varargin{:}] = convertStringsToChars(varargin{:});

% Look for spectrumtype flags: psd, power, and ms window compensation flags
[esttype, extraArgs] = signal.internal.psdesttype({'psd', 'power', 'ms'}, 'psd', varargin);
if strcmpi(esttype, 'ms')
    error(message("signal:welch:InvalidMsLegacyOption", "tall"));
end
% Look for freqrange legacy freqrange options, welchparse will only warn
% and replace 'whole' with 'twosided', and 'half' with 'onesided'.
if any(strcmpi(extraArgs, 'whole')) || any(strcmpi(extraArgs, 'half'))
    error(message("signal:welch:InvalidFreqrangeLegacyOption", "tall"));
end

% Create a sample based on the metadata in the adaptor of x. Use this
% sample and welchparse to parse and validate all the extra arguments.
% options is a struct that contains information about nfft, Fs, range,
% centerdc, average, maxhold, minhold, MIMO, isNFFTSingle.
adaptorX = matlab.bigdata.internal.adaptors.getAdaptor(x);
defaultType = 'double';
defaultSize = [windowLength 1];
sample = buildSample(adaptorX, defaultType, defaultSize);
[~, ~, ~, ~, ~, ~, ~, ~, noverlap, ~, ~, options] = ...
    signal.internal.spectral.welchparse(sample, esttype, extraArgs{:});

% Cast to double to enforce precision rules and save all extra arguments in
% options.
options.nfft = signal.internal.sigcasttofloat(options.nfft, ...
    "double", "WELCH", "NFFT", "allownumeric");
options.noverlap = signal.internal.sigcasttofloat(noverlap, ...
    "double", "WELCH", "NOVERLAP", "allownumeric");
options.Fs = signal.internal.sigcasttofloat(options.Fs, ...
    "double", "WELCH", "Fs", "allownumeric");
options.esttype = esttype;

% options.range has been defined based on the sample in welchparse. This
% sample doesn't have information about the complexity in the tall array x.
% We need to explicitely check which option has been specified as freqrange
% or if the default freqrange applies: 'onesided' for real inputs,
% 'twosided' for complex inputs.
options.range = 'default';
if nargin > 2
    k = 1;
    while k <= numel(extraArgs)
        currentArg = extraArgs{k};
        if (isStringScalar(currentArg) || ischar(currentArg))
            if startsWith('onesided', currentArg, 'IgnoreCase', true)
                options.range = 'onesided';
                extraArgs(k) = [];
            elseif startsWith('twosided', currentArg, 'IgnoreCase', true)
                options.range = 'twosided';
                extraArgs(k) = [];
            elseif startsWith('centered', currentArg, 'IgnoreCase', true)
                options.range = 'centered';
                extraArgs(k) = [];
            else
                k = k + 1;
            end
        else
            k = k + 1;
        end
    end
end

% Check if a frequency vector was specified.
options.IsFreqVector = length(options.nfft) > 1;

% Determine if output is single from the validation. All the outputs are of
% the same type as x or single if window is a single vector.
isOutputSingle = class(win) == "single" || class(sample) == "single";

% Determine if the output type is unknown because we do not know the type
% of x yet. If the input type is unknown but isOutputSingle is true, then
% the ouptut type is single regardless the type of x.
isTypeUnknown = isempty(adaptorX.Class) && ~isOutputSingle;
end

%--------------------------------------------------------------------------
function [sxx, isInputReal, isInputSingle] = iDoPeriodogramWithBlockMovingWindow(x, win, windowLength, ...
    options, isOutputSingle, isTypeUnknown, varargin)
% Compute the periodogram for each segment with
% matlab.tall.blockMovingWindow and the average periodogram if confidence
% intervals are required.

% Set up arguments required for blockMovingWindow: win, windowLength,
% stride/overlap, outputsLike
stride = windowLength - options.noverlap;

% The periodograms computed with blockMovingWindow will be of double
% precision unless x or the window vector (if given by the user) are of
% single precision.
xLike = 1;
if isOutputSingle
    xLike = single(xLike);
end
outputsLike = {xLike};

% Compute the periodogram for each windowed data with blockMovingWindow,
% 'EndPoints' is set to 'discard'. Pwelch takes full-size windows and
% truncates the input signal when there are not enough samples to fill a
% complete window.
periodogramFcn = @(info, x) iBlockPeriodogram(info, isTypeUnknown, x, win, options.nfft, options.esttype, options.Fs);
sxx = matlab.tall.blockMovingWindow([], periodogramFcn, windowLength, x, ...
    'Stride', stride, 'EndPoints', 'discard', 'OutputsLike', outputsLike);

% If the output type was unknown, we can now check the input type and cast
% pxx accordingly.
import matlab.bigdata.internal.broadcast
isInputSingle = isaUnderlying(x, 'single');
if isTypeUnknown
    sxx = slicefun(@(tf, x) iCastIfSingle(tf, x), broadcast(isInputSingle), sxx);
end

% Also check if the input is real or complex, we need to keep track of the
% complexity to apply the default freqrange afterwards.
isInputReal = aggregatefun(@isreal, @all, x);
end

%--------------------------------------------------------------------------
function sxx = iBlockPeriodogram(info, isTypeUnknown, x, win, nfft, esttype, Fs)
% Compute the periodogram for each window assuming that freqrange is
% 'twosided'.

% Perform input signal validation as in welchparse:
validateattributes(x,{'single','double'}, {'finite','nonnan'},'pwelch','x')

% Reshape x in input matrix with getSTFTColumns
windowLength = length(win);
noverlap = windowLength - info.Stride;
xin = signal.internal.stft.getSTFTColumns(x, size(x, 1), windowLength, noverlap, Fs);

sxx = computeperiodogram(xin, win, nfft, esttype, Fs);
% computeperiodogram returns pxx as a column vector, non-conjugate
% transpose it so that we can do the Welch periodogram in the tall
% dimension.
sxx = permute(sxx, [2 1 3]);

% If the input type is unknown, cast to double.
if isTypeUnknown
    sxx = double(sxx);
end
end

%--------------------------------------------------------------------------
function varargout = iCastIfSingle(tf, varargin)
% Cast to single if tf == true
varargout = varargin;

if tf
    for k = 1:numel(varargout)
        varargout{k} = cast(varargout{k}, 'single');
    end
end
end

%--------------------------------------------------------------------------
function f = iCreateFrequencyVectorAndValidateTallSize(~, isInputSingle, isInputReal, sizeXInTallDim, ...
    options, isOutputSingle, windowLength)
% Create the frequency vector from the number of bins of the FFT and Fs.
% Validate the tall size of the input signal, it must be at least equal to
% the window length.

% If the input signal has less time samples than the window length, pwelch
% throws an error. matlab.tall.blockMovingWindow does not call the block
% fuction for this case and returns an empty result. Validate if this is
% the case.
if sizeXInTallDim < windowLength
    error(message('signal:welchparse:invalidSegmentLength'));
end

if options.IsFreqVector
    f = options.nfft;
else
    f = psdfreqvec('npts', options.nfft, 'Fs', options.Fs);
end

if isInputSingle || isOutputSingle
    f = single(f);
end

% Throw a warning if a frequency vector was specified with 'onesided' for a
% real signal.
if options.IsFreqVector && isInputReal && strcmpi(options.range, 'onesided')
    warning(message('signal:welch:InconsistentRangeOption'));
end
end

%--------------------------------------------------------------------------
function [sxx, k, avgSxx] = iComputeAggregatedPeriodogram(inSxx, options)
% Reduce periodograms for each window into an aggregated periodogram based
% on the trace argument: mean (default), maxhold or meanhold. Return the
% average periodogram if requested for the confidence intervals.

k = size(inSxx, 1);

if options.maxhold
    sxx = max(real(inSxx), [], 1);
elseif options.minhold
    sxx = min(real(inSxx), [], 1);
else
    sxx = mean(inSxx, 1);
end

if nargout > 2
    avgSxx = mean(inSxx, 1);
end
end

%--------------------------------------------------------------------------
function varargout = iComputePSDAndConfInterval(options, isInputReal, numSegments, f, sxx, avgSxx)
% Compute PSD and ConfIntervals.

% Pxx has been reduced to a 1-by-nfft vector or 1-by-nfft-by-numChannels
% ND-array, remove singleton dimensions to match the output format of
% in-memory pwelch (frequency vs. channels).
sxx = permute(sxx, [2 3 1]);

if nargin > 5
    avgSxx = permute(avgSxx, [2 3 1]);
else
    avgSxx = sxx;
end

% Now that we know if the input is real or complex, set up the
% corresponding freqrange option.
if options.range == "default"
    if isInputReal
        options.range = 'onesided';
    else
        options.range = 'twosided';
    end
end

% Compute PSD and format output for 'twosided' or 'onesided' 
[pxx, w, ~] = computepsd(sxx, f, options.range, options.nfft, options.Fs, options.esttype);

% Compute PSD of the average periodogram for the confidence intervals if
% requested.
pxxc = [];
if nargout > 2
    [avgPxx, ~, ~] = computepsd(avgSxx, f, options.range, options.nfft, options.Fs, options.esttype);
    if isnan(options.conflevel)
        confLevel = 0.95;
    else
        confLevel = options.conflevel;
    end
    % Cast to enforce precision rules
    avgPxx = double(avgPxx);
    pxxc = signal.internal.spectral.confInterval(confLevel, avgPxx, isInputReal, f, options.Fs, numSegments);
end

% Center all the outputs if 'centered' was specified for freqrange.
if options.centerdc
    [pxx, w, pxxc] = signal.internal.spectral.psdcenterdc(pxx, w, pxxc, options, options.esttype);
end

% If the input is a vector and a row frequency vector was specified,
% return output as a row vector for backwards compatibility.
if isvector(pxx) && numel(options.nfft)>1 && isrow(options.nfft)
    pxx = pxx.';
    w = w.';
end

% Set all the requested outputs
outputs = {pxx,w,pxxc};
varargout = outputs(1:nargout);
end

%--------------------------------------------------------------------------
function varargout = iSetOutputAdaptors(x, win, nfft, varargin)
% Set the output adaptors with available information from the input signal
% and the window argument.

varargout = varargin;

xAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(x);
winAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(win);
if isTypeKnown(xAdaptor)
    % Combine adaptors to set up the underlying type of the output. Window
    % argument is a non-tall argument and we always know its type.
    outAdaptor = matlab.bigdata.internal.adaptors.combineAdaptors(1, ...
        {resetSizeInformation(xAdaptor); resetSizeInformation(winAdaptor)});
else
    % If the underlying type of x is unknown, we don't propagate any type.
    outAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('');
end
% All the outputs are vector or matrices, we can set up the number of
% dimensions to 2.
outAdaptor = setKnownSize(outAdaptor, [NaN NaN]);

% In most of the cases, the number of columns in pxx matches the number of
% columns in x, this is, the number of channels in x. Only when x is a
% vector and a frequency vector is given as a row vector, pxx and f will be
% row vectors instead.
freqRowVector = numel(nfft)>1 && isrow(nfft);
if freqRowVector && isKnownVector(xAdaptor)
    % Pxx is a row vector.
    varargout{1}.Adaptor = setSizeInDim(outAdaptor, 1, 1);
elseif ~freqRowVector
    % Pxx is a column vector or a matrix with as many columns as x.
    varargout{1}.Adaptor = setSizeInDim(outAdaptor, 2, xAdaptor.Size(2));
else
    % Pxx might be a column/row vector or matrix.
    varargout{1}.Adaptor = outAdaptor;
end

if nargout > 1
    % Frequency vector is a column vector for all the cases except when the
    % frequency vector is given as a row vector and input x is a vector.
    if freqRowVector && isKnownVector(xAdaptor)
        % Frequency vector is a row vector.
        varargout{2}.Adaptor = setSizeInDim(outAdaptor, 1, 1);
    elseif ~freqRowVector
        % Frequency vector is a column vector.
        varargout{2}.Adaptor = setSizeInDim(outAdaptor, 2, 1);
    else
        % Frequency vector migth be a column/row vector.
        varargout{2}.Adaptor = outAdaptor;
    end
    
    if nargout > 2
        % The underlying type of Pxx is always double. Its second dimension
        % is twice the number of channels in x.
        pxxcAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
        pxxcAdaptor = setKnownSize(pxxcAdaptor, [NaN NaN]);
        pxxcAdaptor = setSizeInDim(pxxcAdaptor, 2, 2*xAdaptor.Size(2));
        varargout{3}.Adaptor = pxxcAdaptor;
    end
end
end

%--------------------------------------------------------------------------
function iPlotPwelch(windowLength, options, isInputReal, varargin)
% Plot pwelch.

% Set up plotting arguments.
winName  = 'User Defined';
winParam = '';
if ~isempty(options.Fs) && ~isnan(options.Fs)
    units = 'Hz';
else
    units = 'rad/sample';
end

% Gather outputs and information about input complexity.
outputs = cell(1, numel(varargin));
[isInputReal, outputs{:}] = gather(isInputReal, varargin{:});
% Outputs are Pxx, w, and Pxxc. Pxx and w are always computed, set empty
% Pxxc if confidence intervals haven't been requested.
if numel(outputs) < 3
    outputs = [outputs, {[]}];
end

% Set up the corresponding freqrange option.
if options.range == "default"
    if isInputReal
        options.range = 'onesided';
    else
        options.range = 'twosided';
    end
end

% Call internal helper to plot pwelch.
signal.internal.spectral.plotWelch(outputs{:},...
        options.esttype, options.noverlap, windowLength, winName, winParam, units, options);
end