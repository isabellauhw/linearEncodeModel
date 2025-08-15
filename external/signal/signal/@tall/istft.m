function [x, t] = istft(s, varargin)
%ISTFT Inverse short-time Fourier transform for tall arrays
%
%   X = ISTFT(S,'InputTimeDimension',TIMEDIMENSION)
%   X = ISTFT(S,FS,'InputTimeDimension',TIMEDIMENSION)
%   X = ISTFT(S,TS,'InputTimeDimension',TIMEDIMENSION)
%   X = ISTFT(...,'Window',WINDOW)
%   X = ISTFT(...,'OverlapLength',NOVERLAP)
%   X = ISTFT(...,'FFTLength',NFFT)
%   X = ISTFT(...,'Method',METHOD)
%   X = ISTFT(...,'ConjugateSymmetric',CONJUGATESYMMETRIC)
%   X = ISTFT(...,'FrequencyRange',FREQRANGE)
%   [X,T] = ISTFT(...)
%
%   Limitations:
%   1. InputTimeDimension must be always specified and set to 'downrows'.
%
%   See also ISTFT, STFT, TALL.

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(1, 16);
nargoutchk(0, 2);

[s, opts] = iParseArguments(s, varargin{:});

% Each block of the tall array S contains the DFT for M windows, being of
% size: M-by-min(windowLength, nfft).
% Use stencilfun to get as many windows as required to recovered the signal
% in each block of the tall array. Make sure that we remove the padding
% added to each block in order to avoid duplication of samples. The number
% of overlapped samples and the stride define the number of windows needed
% for padding.
stride = opts.WindowLength - opts.OverlapLength;
numRequiredWindows = ceil(opts.OverlapLength/stride);
halo = [numRequiredWindows 0];
stencilFcn = @(info, s) iStencilIFFTAndOverlapAdd(info, opts, s);
if opts.OverlapLength > 0
    % This is a stencil operation
    [x, normValues] = stencilfun(stencilFcn, halo, s);
else
    % This is a chunkwise operation, no padding is required from contiguous
    % blocks.
    stencilInfo.Window = halo;
    stencilInfo.Padding = halo;
    stencilInfo.StartIndex = [];
    stencilInfo.IsHead = false;
    stencilInfo.IsTail = false;
    [x, normValues] = chunkfun(@(x) stencilFcn(stencilInfo, x), s);
end
if opts.IsSingle
    x.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('single');
else
    x.Adaptor = resetSmallSizes(resetTallSize(matlab.bigdata.internal.adaptors.getAdaptor(s)));
end

% Normalized recovered signal x
import matlab.bigdata.internal.broadcast
numSegments = size(s, 1); % Number of segments/windows in the input time-frequency map
x = slicefun(@iNormalizeRecoveredSignal, x, normValues, broadcast(numSegments));

% Create time vector
t = getAbsoluteSliceIndices(x);
% Scale time vector with sample rate and update if duration was provided.
isOutputSingle = isaUnderlying(x, 'single');
t = elementfun(@(varargin) scaleAndCastTimeVector(opts, varargin{:}), t, broadcast(isOutputSingle));
adaptorX = matlab.bigdata.internal.adaptors.getAdaptor(x);
if strcmpi(opts.TimeMode, 'ts')
    % Sample Time Ts was provided and t is a duration array as Ts.
    adaptorT = matlab.bigdata.internal.adaptors.getAdaptorForType('duration');
else
    % Otherwise, t has the same type as the recovered signal x.
    adaptorT = adaptorX;
end
t.Adaptor = copySizeInformation(adaptorT, adaptorX);
t.Adaptor = setSmallSizes(t.Adaptor, 1);
end

%--------------------------------------------------------------------------
function [s, opts] = iParseArguments(s, varargin)
% Parse input arguments of tall/istft using the same parser as in-memory
% ISTFT and a sample with fake data based on the tall input adaptor.

% Only input time-frequency map can be tall
tall.checkIsTall(upper(mfilename), 0, s);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% s must be a double or single matrix or 3D array
s = tall.validateTypeWithError(s, 'istft', 1, {'double', 'single'}, 'signal:istft:InvalidInputDataType');

% Before validating input arguments with in-memory stft, we need to parse
% the window argument to specify the minimum width of the sample. Its size
% in the second dimension (frequency) must be greater than or equal to the
% window length. Default window is a Hann window of length 128.
% We also need to identify if 'onesided' has been specified as the
% frequency range and get the specified FFT length. By default, FFT length
% is equal to the window length.
windowLength = 128;
isOnesided = false;
isNFFTSpecified = false;
nfft = windowLength;
if nargin > 2
    k = 1;
    while k < numel(varargin)
        % Loop through varargin to check if 'Window' name-value pair has
        % been specified, if 'FrequencyRange' has been specified, and if
        % 'NFFTLength' has been specified.
        % When 'FrequencyRange' is set to 'onesided', the number of columns
        % of the input S is equal to half the FFTLength. We need to check
        % for this in order to create an appropriate sample.
        currentArg = varargin{k};
        if (isStringScalar(currentArg) || ischar(currentArg)) ...
                && startsWith('Window', currentArg, 'IgnoreCase', true)
            win = varargin{k+1};
            % Get window and validate. Window must be a vector with a
            % window function.
            validateattributes(win, {'single', 'double'}, ...
                {'nonempty', 'finite', 'nonnan', 'vector', 'real'}, 'istft', 'Window');
            win = win(:);
            windowLength = length(win);
            validateattributes(windowLength, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative', 'real', 'nonnan', 'nonempty', ...
                'finite', '>', 1}, 'istft', 'WindowLength');
            if ~isNFFTSpecified
                nfft = windowLength;
            end
        elseif (isStringScalar(currentArg) || ischar(currentArg)) ...
                && startsWith('FrequencyRange', currentArg, 'IgnoreCase', true) ...
                && startsWith('onesided', varargin{k+1}, 'IgnoreCase', true)
            isOnesided = true;
        elseif (isStringScalar(currentArg) || ischar(currentArg)) ...
                && startsWith('FFTLength', currentArg, 'IgnoreCase', true)
            isNFFTSpecified = true;
            nfft = varargin{k+1};
            validateattributes(nfft,{'numeric'},...
                {'scalar','integer','nonnegative','real','nonnan',...
                'finite','nonempty','>=', windowLength}, 'istft' ,'FFTLength');
        end
        k = k + 1;
    end
end

% Build a sample based on the available metadata in the adaptor of s.
adaptor = matlab.bigdata.internal.adaptors.getAdaptor(s);
if isOnesided
    if signalwavelet.internal.iseven(nfft)
        halfFFTLength = nfft/2+1;
    else
        halfFFTLength = (nfft+1)/2;
    end
    defaultSize = [windowLength halfFFTLength];
else
    defaultSize = [windowLength windowLength];
end
defaultType = 'double';
sample = buildSample(adaptor, defaultType, defaultSize);

% Call the in-memory STFT/ISTFT parser to get all the parsed arguments or
% default values in opts. It will also validate the input arguments as
% in-memory ISTFT.
[~, opts] = signal.internal.stft.stftParser('istft', sample, varargin{:});

% For tall/istft, 'InputTimeDimension' must be always set to 'downrows'.
ensureTallTimeDownrows(opts.TimeDimension, true);
end

%--------------------------------------------------------------------------
function [x, normVal] = iStencilIFFTAndOverlapAdd(info, opts, s)
% Computes inverse short-time Fourier transform per block of the tall array
% without normalization.

% Get the number of channels and windows/segments in the current block.
% With 'downrows', s is of size numSegments-by-nfft-by-numChannels.
numChannels = size(s, 3);
numSegments = size(s, 1) - sum(info.Padding);

classCast = class(s);
% Output will be single if the provided window was single. If this is the
% case, cast s to 'single'.
if opts.IsSingle
    s = cast(s, 'single');
    classCast = 'single';
end

if numSegments == 0
    % No data slices, only padding in this block. Return empty outputs of
    % the same type.
    x = zeros(0, numChannels, classCast);
    normVal = zeros(0, numChannels, classCast);
    return;
end

% Compute IFFT and OverlapAdd to this block
[x, normVal] = iComputeIFFTAndOverlapAddPerBlock(opts, s);

% Define slices to keep from x and normVal. Each segment in s generates a
% column vector/matrix of size min(windowLength, nfft)-by-numChannels. Each
% generated output will be overlapped by noverlap samples with the output
% generated by the contiguous segments.
firstSegment = 1 + info.Padding(1);
lastSegment = size(s, 1) - info.Padding(2);
stride = opts.WindowLength - opts.OverlapLength;

firstSampleInX = (firstSegment-1)*stride + 1;

if info.IsTail && info.Padding(2) == 0
    % Absolute tail, include the slices for the last window since they do
    % not overlap with anything else.
    lastSampleInX = (lastSegment-1)*stride + opts.WindowLength;
else
    % Head, body blocks or partial tail blocks. Keep the slices from the
    % beginning of the first data window in this block (not coming from the
    % head padding) and the beginning of the first window in the tail
    % padding.
    lastSampleInX = lastSegment*stride;
end
samplesToKeep = firstSampleInX:lastSampleInX;

x = x(samplesToKeep, :);
normVal = normVal(samplesToKeep, :);
end

%--------------------------------------------------------------------------
function [x, normVal] = iComputeIFFTAndOverlapAddPerBlock(opts, s)
% Computes inverse short-time Fourier transform per block of the tall array
% without normalization. Based on signal/istft/computeISTFT.

% Get the number of channels and windows/segments in the current block:
% with 'downrows' s is of size numSegments-by-nfft-by-numChannels.
numChannels = size(s, 3);
numSegments = size(s, 1);

classCast = class(s);

% Set variables
win = opts.Window;
nwin = opts.WindowLength;
noverlap = opts.OverlapLength;
nfft = opts.FFTLength;
hop = nwin-noverlap;
xlen = nwin + (numSegments-1)*hop;

% Before doing any further processing, convert to default orientation with
% size nfft-by-numSegments-by-numChannels
s = permute(s, [2, 1, 3]);

% Format STFT to twosided
s = signal.internal.stft.formatISTFTInput(s,opts);

% IDFT
if opts.ConjugateSymmetric
    xifft = ifft(s, nfft, 1, 'symmetric');
else
    xifft = ifft(s, nfft, 1, 'nonsymmetric');
end

xifft = xifft(1:min(nwin, size(xifft, 1)), 1:numSegments, 1:numChannels);

% Initialize time-domain signal
if isreal(xifft)
    x = zeros(xlen, 1, numChannels, classCast);
else
    x = complex(zeros(xlen, 1, numChannels, classCast));
end

% Set method
if strcmpi(opts.Method, 'ola')
    a = 0;
else % Else WOLA
    a = 1;
end

% Initialize normalization value
normVal = zeros(xlen, numChannels);
winNominator = win.^a;
winDenominator = win.^(a+1);

% Overlap-add in this block
for ii = 1:numSegments
    x(((ii-1)*hop+1):((ii-1)*hop+nwin),1,:) = x(((ii-1)*hop+1):((ii-1)*hop+nwin),1,:) ...
        + xifft(:,ii,:).*winNominator;
    normVal(((ii-1)*hop+1):((ii-1)*hop+nwin),:) = normVal(((ii-1)*hop+1):((ii-1)*hop+nwin),:) + winDenominator;
end
x = squeeze(x);
end

%--------------------------------------------------------------------------
function x = iNormalizeRecoveredSignal(x, normValues, numSegments)
% Normalize recovered signal x with the computed normalization values.

% Avoid normalization of small values
normValues(normValues<(numSegments*eps)) = 1;
x = x./normValues;
end

%--------------------------------------------------------------------------
function t = scaleAndCastTimeVector(opts, t, isInputSingle)
% Scale time vector with sample rate and cast to single or duration
% accordingly.

% Convert the time vector from 1-based to 0-based
t = t - 1;

% Apply sample rate if it isn't a normalized frequency
if ~opts.IsNormalizedFreq
    t = t./opts.EffectiveFs;
end

% Cast to single if single input
if isInputSingle
    t = cast(t, 'single');
end

% Update time vector if duration Ts was provided
if strcmpi(opts.TimeMode, 'ts')
    t = seconds(t);
    t.Format = opts.TimeUnits;
end
end