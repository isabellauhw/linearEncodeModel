function varargout = spectrogram(x, varargin)
%SPECTROGRAM Spectrogram using a Short-Time Fourier Transform (STFT).
%
%   S = SPECTROGRAM(X,WINDOW,'OutputTimeDimension',TIMEDIMENSION)
%   S = SPECTROGRAM(X,WINDOW,NOVERLAP,'OutputTimeDimension',TIMEDIMENSION)
%   S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT,'OutputTimeDimension',TIMEDIMENSION)
%   [S,W,T] = SPECTROGRAM(...)
%   [S,F,T] = SPECTROGRAM(...,FS)
%   [S,W,T] = SPECTROGRAM(X,WINDOW,NOVERLAP,W,'OutputTimeDimension',TIMEDIMENSION)
%   [S,F,T] = SPECTROGRAM(X,WINDOW,NOVERLAP,F,FS,'OutputTimeDimension',TIMEDIMENSION)
%   [...,PS] = SPECTROGRAM(...)
%   [...,PS,FC,TC] = SPECTROGRAM(...)
%   [...] = SPECTROGRAM(...,FREQRANGE)
%   [...] = SPECTROGRAM(...,SPECTRUMTYPE)
%   [...] = SPECTROGRAM(...,'MinThreshold', THRESH)
%
%   Limitations:
%   1. X must be a tall column vector.
%   2. WINDOW argument must be always specified.
%   3. OutputTimeDimension must be always specified and set to 'downrows'.
%   4. Syntaxes with no output arguments are not supported.
%   5. 'reassigned' option is not supported.
%
%   See also SPECTROGRAM, TALL.

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(1, 11);
nargoutchk(0, 6);

if nargout == 0
    error(message('signal:tall:ZeroOutputArgsNotSupported', mfilename));
end

% Parse all input arguments and validate with in-memory spectrogram.
% Frequency vector f does not have the same height as S, P, t, FC and TC.
% matlab.tall.blockMovingWindow requires all the output arguments to have
% the same height. Compute f as part of the validation. It can be defined
% by the FFT length and Fs, or it may have been provided as an input
% argument.
[x, win, windowLength, freqOptions, isOutputSingle, isUnknownType, varargin] = iParseArguments(x, varargin{:});

% Get all the outputs with matlab.tall.blockMovingWindow except from f,
% which has been already computed.
[varargout{1:nargout}] = iDoSpectrogramWithBlockMovingWindow(x, win, ...
    windowLength, freqOptions, isOutputSingle, isUnknownType, varargin{:});

% Extract some useful information known upfront to set the output adaptors.
[varargout{1:nargout}] = iSetOutputAdaptors(x, win, varargout{:});

%--------------------------------------------------------------------------
function [x, win, windowLength, freqOptions, isOutputSingle, isUnknownType, varargin] = iParseArguments(x, varargin)
% Parse input arguments of tall/spectrogram with tall.validateSyntax and
% in-memory spectrogram. Also, compute the frequency vector f with
% tall.validateSyntax.

% Only input signal x can be tall
tall.checkIsTall(upper(mfilename), 0, x);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% x must be a tall column vector
x = ensureTallColumn(x);

% Check that OutputTimeDimension has been specified and set to 'downrows'.
% Extract the name-value pair from varargin to proceed with the validation
% and extraction of positional arguments as window or noverlap.
% Also check if optional argument 'reassigned' has been provided since it
% is not supported for tall. If given, throw a comprehensive error.
timeDimension = 'acrosscolumns';
freqrange = 'default';
if nargin > 2
    k = 1;
    while k <= numel(varargin)
        currentArg = varargin{k};
        % Loop through varargin to check:
        % (1) If 'OutputTimeDimension' name-value pair has been specified.
        % (2) If optional argument 'reassigned' has been specified.
        % (3) Whether an option has been specified as freqrange or if the
        % default freqrange applies.
        % (4) If a legacy option for freqrange has been specified:
        % whole/half.
        % (5) If a legacy option for spectrum type has been specified: ms.
        if (isStringScalar(currentArg) || ischar(currentArg))
            if k < numel(varargin) ...
                    && startsWith('OutputTimeDimension', currentArg, 'IgnoreCase', true) ...
                    && startsWith('downrows', varargin{k+1}, 'IgnoreCase', true)
                timeDimension = 'downrows';
                varargin([k k+1]) = [];
            elseif startsWith('reassigned', currentArg, 'IgnoreCase', true)
                error(message('signal:spectrogram:ReassignedNotSupportedForTall'));
            elseif startsWith('onesided', currentArg, 'IgnoreCase', true)
                freqrange = 'onesided';
                varargin(k) = [];
            elseif startsWith('twosided', currentArg, 'IgnoreCase', true)
                freqrange = 'twosided';
                varargin(k) = [];
            elseif startsWith('centered', currentArg, 'IgnoreCase', true)
                freqrange = 'centered';
                varargin(k) = [];
            elseif startsWith('whole', currentArg, 'IgnoreCase', true)
                error(message('signal:spectrogram:InvalidFreqrangeLegacyOption', 'tall'));
            elseif startsWith('half', currentArg, 'IgnoreCase', true)
                error(message('signal:spectrogram:InvalidFreqrangeLegacyOption', 'tall'));
            elseif startsWith('ms', currentArg, 'IgnoreCase', true)
                error(message('signal:spectrogram:InvalidMsLegacyOption', 'tall'));
            else
                k = k + 1;
            end
        else
            k = k + 1;
        end
    end
end

% For tall/spectrogram, 'OutputTimeDimension' must be always set to
% 'downrows'.
ensureTallTimeDownrows(timeDimension, false);

% Check that window is double/single scalar or vector and throw same error
% as welchparse. It cannot be []. Extract window from varargin or throw a
% comprehensive error message when window argument is not provided.
if isempty(varargin)
    error(message('signal:spectrogram:WindowMustBeProvidedForTall'));
end
win = varargin{1};
varargin(1) = [];
if ~any(size(win) == 1)
    error(message('signal:welchparse:MustBeScalarOrVector', 'WINDOW'));
end

if ~isscalar(win)
    % User-defined window
    validateattributes(win,{'double','single'},{'nonsparse'},'spectrogram','Window');
    windowLength = length(win);
else
    % Cast to double scalar window
    win = double(win);
    windowLength = win;
end

% Use in-memory spectrogram to validate input arguments with
% tall.validateSyntax. It creates a sample based on the metadata in the
% adaptor of x and with as many samples as the window. Extract the vector
% of frequencies f as it is defined by the FFT length and Fs, or it may
% have been provided as an input argument.
x = tall.validateTypeWithError(x, 'spectrogram', 1, {'double', 'single'}, {'signal:spectrogram:MustBeFloat', 'x'});

% Perform the validation with two samples (real and complex) to check if
% the user has provided a frequency vector. If a frequency vector is
% provided, the output frequency vector will be the same for real and
% complex inputs.
% Assume default behaviour for freqrange unless 'centered' is provided
% ('onesided' for real signals and 'twosided' for complex signals) so that
% we can detect if the frequency vector was provided.
if strcmpi(freqrange, 'centered')
    varargin = [varargin, 'centered'];
end
[~, fReal] = tall.validateSyntax(@spectrogram, [{x}, {win}, [varargin, 'OutputTimeDimension', 'downrows']], ...
    'DefaultType', 'double', 'DefaultSize', [windowLength 1], 'NumOutputs', 2);
[~, fComplex] = tall.validateSyntax(@iSpectrogram, [{x}, {win}, [varargin, 'OutputTimeDimension', 'downrows']], ...
    'DefaultType', 'double', 'DefaultSize', [windowLength 1], 'NumOutputs', 2);

% If the input signal is real, the default freqrange and 'onesided' have a
% different behaviour depending on whether a frequency vector has been
% specified.
isFreqVector = false;
if isequal(fReal, fComplex) && any(strcmpi(freqrange, {'onesided', 'default'}))
    isFreqVector = true;
end

% Determine if output is single from the validation. All the outputs are of
% the same type as x or single if window is a single vector.
isOutputSingle = class(fReal) == "single";

% Determine if the output type is unknown because we do not know the type
% of x yet. If the input type is unknown but isOutputSingle is true, then
% the ouptut type is single regardless the type of x.
adaptorX = matlab.bigdata.internal.adaptors.getAdaptor(x);
isUnknownType = isempty(adaptorX.Class) && ~isOutputSingle;

% Wrap all frequency parameters in fOptions
freqOptions = struct( ...
    'FReal', fReal, ...
    'FComplex', fComplex, ...
    'FreqRange', freqrange, ...
    'IsFreqVector', isFreqVector);

%--------------------------------------------------------------------------
function [S, f] = iSpectrogram(x, win, varargin)
% Validate syntax of spectrogram and create frequency vector assuming that
% the signal is always complex. Since the input will be complex, default
% spectrum is 'twosided' unless 'centered' is provided in varargin.
[S, f] = spectrogram(complex(x), win, varargin{:});

%--------------------------------------------------------------------------
function varargout = iDoSpectrogramWithBlockMovingWindow(x, win, windowLength, freqOptions, isOutputSingle, isUnknownType, varargin)
% Call spectrogram with matlab.tall.blockMovingWindow.
% matlab.tall.blockMovingWindow calls in-memory spectrogram with blocks of
% the tall array that only contain full-size windows of data. It is
% expected that in-memory spectrogram will return as many rows as the
% number of windows in the the given block.

% Unwrap parsed frequency parameters in freqOptions
fReal = freqOptions.FReal;
fComplex = freqOptions.FComplex;
freqrange = freqOptions.FreqRange;
isFreqVector = freqOptions.IsFreqVector;

% Lazily check if the input is real and compute the size in the tall
% dimension to validate against the window length.
isInputReal = aggregatefun(@isreal, @all, x);
[sizeInTallDim, ~] = size(x);

% matlab.tall.blockMovingWindow requires: window length, stride, endPoints
% handling and outputsLike
optionalArgs = varargin;
% Extract noverlap or define default. noverlap is the first argument in
% varargin.
if isempty(varargin)
    % Default number of overlap samples, 50% window length.
    noverlap = fix(0.5.*windowLength);
elseif isempty(varargin{1})
    % Placeholder for noverlap. Define default and remove noverlap from
    % optionalArgs.
    noverlap = fix(0.5*windowLength);
    optionalArgs(1) = [];
else
    noverlap = optionalArgs{1};
    if ~isnumeric(noverlap) || ~isscalar(noverlap) || noverlap ~= floor(noverlap)
        error(message('signal:welchparse:invalidNoverlap'));
    end
    optionalArgs(1) = [];
end
% Compute stride for matlab.tall.blockMovingWindow from noverlap and
% windowLength.
stride = windowLength - noverlap;

% Define OutputsLike with the correct small sizes for all of the output
% arguments. If the expected output is single, also specify that the output
% type is single.
if isOutputSingle
    % x, ps, fc, and tc are matrices of the same number of columns as
    % number of samples in fComplex.
    outLike = ones(1, length(fComplex), "single");
    % t is a column vector
    tLike = single(1);
else
    % At this point, the output type is double or it might be the case
    % where the input type is unknown. For any of these cases, consider
    % that all the outputs are double. x, ps, fc, and tc are matrices of
    % the same number of columns as the number of samples in fComplex.
    outLike = ones(1, length(fComplex));
    % t is a column vector
    tLike = 1;
end
% Assign outputsLike for all output arguments except f.
numOutputs = max(1, nargout-1);
outputsLike = cell(1, numOutputs);
for k = 1:numOutputs
    % The second output argument t is a vector.
    if k ~= 2
        outputsLike{k} = outLike;
    else
        % t vector
        outputsLike{k} = tLike;
    end
end

% Define function handle for blockMovingWindow, we must include
% 'OutputTimeDimension' back to optionalArgs so that we can vertically
% concatenate the blocks of the tall array.
optionalArgs = [optionalArgs, 'OutputTimeDimension', 'downrows'];

if ~strcmpi(freqrange, 'centered')
    % If 'centered' was not provided as a freqrange option, force the
    % spectrum to be 'twosided' for real and complex signals.
    optionalArgs = [optionalArgs, 'twosided'];
end
specFcn = @(info, x) iBlockSpectrogram(isUnknownType, x, win, info.Window - info.Stride, optionalArgs{:});

% Use matlab.tall.blockMovingWindow to get the requested outputs excluding
% f, which has been already computed. EndPoints is set to 'discard',
% spectrogram takes full-size windows and truncates the input signal at the
% end if there are not enough samples to fill a complete window.
[out{1:max(1, nargout-1)}] = matlab.tall.blockMovingWindow([], specFcn, windowLength, x, ...
    'Stride', stride, 'EndPoints', 'Discard', 'OutputsLike', outputsLike);

% If the data input has less time samples than the window length,
% spectrogram throws an error. matlab.tall.blockMovingWindow does not call
% the block function for this case and returns an empty result. Also select
% f from fReal or fComplex depending on the complexity of x and the given
% freqrange.
import matlab.bigdata.internal.broadcast
[f, isInputReal] = clientfun(@(varargin) iPickFrequencyVectorAndValidateTallSize(varargin{:}, fReal, fComplex, isFreqVector, freqrange, windowLength), ...
    out{1}(1,:), broadcast(isInputReal), broadcast(sizeInTallDim));

% If the output type was unknown, we can now check the input type and cast
% the outputs accordingly.
if isUnknownType
    isInputSingle = isaUnderlying(x, 'single');
    isInputSingle = broadcast(isInputSingle);
    [out{1:max(1, nargout-1)}] = slicefun(@(tf, varargin) iCastIfSingle(tf, varargin{:}), isInputSingle, out{:}); 
end

% All the outputs of spectrogram have been computed with 'twosided'
% freqrange unless 'centered' was provided. Format the spectrogram and
% outputs ps, fc, and tc to match the default freqrange or error if the
% input signal was complex and 'onesided' was specified.
[out{1:max(1, nargout-1)}] = slicefun(...
    @(isInputReal, varargin) iCreateOnesidedIfRealInput(isInputReal, isFreqVector, freqrange, fReal, fComplex, varargin{:}), ...
    broadcast(isInputReal), out{:});

varargout = cell(1, nargout);
varargout{1} = out{1};
% Place f vector in varargout (s, f, t, ps, fc, tc)
if nargout > 1
    varargout{2} = f;
    % If the input type was unknown, check now and cast f accordingly.
    if isUnknownType
        varargout{2} = slicefun(@(tf, x) iCastIfSingle(tf, x), isInputSingle, varargout{2});
    end
    if nargout > 2
        varargout(3:end) = out(2:end);
    end
end

% t and tc if requested, must be scaled up according to the number of
% blocks in the tall array.
if nargout > 2
    % t can be defined from stride, windowLength and fs. Extract fs if
    % given as the 5th argument of spectrogram (3rd numeric argument in
    % varargin). If it is not given, define default.
    if numel(varargin) < 3 || ischar(varargin{3}) || isStringScalar(varargin{3})
        % Default Fs is 2*pi for normalized frequencies.
        fs = 2*pi;
    elseif isempty(varargin{3})
        % Default Fs is 1Hz.
        fs = 1;
    else
        fs = varargin{3};
    end
    
    % t is in the 3rd output
    oldT = varargout{3};
    paOldT = hGetValueImpl(oldT);
    partitionSizes = matlab.bigdata.internal.lazyeval.getPartitionSizes(paOldT);
    partitionSizes = broadcast(partitionSizes);
    if nargout > 5
        % tc is the 6th output
        oldTc = varargout{6};
        paOldTc = hGetValueImpl(oldTc);
        [paT, paTC] = partitionfun(@(varargin) iScaleTimeVectorAndMatrix(varargin{:}, fs, stride, windowLength), partitionSizes, paOldT, paOldTc);
        adaptorTC = matlab.bigdata.internal.adaptors.getAdaptor(oldTc);
        varargout{6} = tall(paTC, adaptorTC);
        varargout{6} = copyPartitionIndependence(varargout{6}, oldTc);
    else
        paT = partitionfun(@(varargin) iScaleTimeVectorAndMatrix(varargin{:}, fs, stride, windowLength), ...
            partitionSizes, paOldT, broadcast([]));
    end
    adaptorT = matlab.bigdata.internal.adaptors.getAdaptor(oldT);
    varargout{3} = tall(paT, adaptorT);
    varargout{3} = copyPartitionIndependence(varargout{3}, oldT);
end

%--------------------------------------------------------------------------
function varargout = iBlockSpectrogram(isUnknownType, x, win, noverlap, varargin)
% Compute spectrogram for this block of the tall array using in-memory
% spectrogram.

isMultipleOutput = nargout > 1;
% If multiple arguments are requested, compute the requested arguments and
% the frequency vector f with in-memory spectrogram.
[varargout{1:nargout + isMultipleOutput}] = spectrogram(x, win, noverlap, varargin{:});

% Do not return f. It has been previously computed.
if isMultipleOutput
    varargout(2) = [];
end

% If output type is unknown cast to double
if isUnknownType
    for k = 1:length(varargout)
        varargout{k} = double(varargout{k});
    end
end

%--------------------------------------------------------------------------
function [f, isInputReal] = iPickFrequencyVectorAndValidateTallSize(~, isInputReal, sizeInTallDim, fReal, fComplex, isFreqVector, freqrange, windowLength)
% Select the output frequency vector according to the complexity of the
% input signal and the frequency range.

if isInputReal && any(strcmpi(freqrange, {'default', 'onesided'}))
    f = fReal;
else
    % Real signal with 'twosided' or 'centered' spectrogram, or complex
    % signal.
    f = fComplex;
end

% Validate if the input signal has as many samples as the window length.
if sizeInTallDim < windowLength
    error(message('signal:welchparse:invalidSegmentLength'));
end

% Throw a warning if a frequency vector was specified with 'onesided' for a
% real signal.
if isFreqVector && isInputReal && strcmpi(freqrange, 'onesided')
    warning(message('signal:welch:InconsistentRangeOption'));
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

%--------------------------------------------------------------------------
function [varargout] = iCreateOnesidedIfRealInput(isInputReal, isFreqVector, freqrange, fReal, fComplex, varargin)
% Spectrogram outputs have been computed as 'twosided' unless 'centered'
% was specified. Format the spectrogram outputs according to: complexity of
% the signal, default or given freqrange, and if a frequency vector was
% provided by the user or not.

varargout = varargin;

if ~isInputReal
    % Complex signals. Default freqrange is 'twosided', check that
    % 'onesided' was not requested.
    if strcmpi(freqrange, 'onesided')
        error(message('signal:psdoptions:ComplexInputDoesNotHaveOnesidedPSD'));
    end
    return;
end

% Real signal. If 'twosided' or 'centered' were requested we can just
% return.
if ~any(strcmpi(freqrange, {'default', 'onesided'}))
    return;
end

% Check if a frequency vector was provided to return 'twosided'
% spectrogram.
if isFreqVector
    return;
end

% Return 'onesided' spectrogram, freqrange is default or 'onesided' and the
% user did not provide a frequency vector.
% We need the number of FFT bins, given by the length of the frequency
% vector when the input is complex.
nfft = length(fComplex);
for k = 1:numel(varargin)
    twosidedOut = varargin{k};
    if k == 3
        % PSD needs rescaling (4th output), apply same processing as
        % computepsd.
        onesidedOut = twosidedOut(:, 1:length(fReal));
        if mod(nfft, 2) == 0 % nfft is even
            varargout{k} = [onesidedOut(:, 1) 2*onesidedOut(:, 2:end-1) onesidedOut(:, end)];
        else
            varargout{k} = [onesidedOut(:, 1) 2*onesidedOut(:, 2:end)];
        end
    elseif size(twosidedOut, 2) > 1
        % varargin contains the time vector, do not modify it
        varargout{k} = twosidedOut(:, 1:length(fReal));
    else
        varargout{k} = twosidedOut;
    end
end

%--------------------------------------------------------------------------
function [isFinished, t, tc] = iScaleTimeVectorAndMatrix(info, partitionSizes, oldT, oldTc, fs, stride, windowLength)
% Create time vector t considering the position of this block within the
% tall array. If requested, scale matrix tc by the time vector for this
% block.
isFinished = info.IsLastChunk;

t = oldT;
if ~isempty(oldT)
    initialPosition = sum(partitionSizes(1:info.PartitionId - 1)) + info.RelativeIndexInPartition;
    idx = initialPosition + (0:size(oldT, 1)-1).' - 1;
    idx = cast(idx, 'like', oldT);
    t = ((idx.*stride) + windowLength/2)./fs;
end

tc = oldTc;
if ~isempty(oldTc)
    tc = oldTc - oldT + t;
    tc = cast(tc, 'like', oldTc);
end

%--------------------------------------------------------------------------
function varargout = iSetOutputAdaptors(x, win, varargin)
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

% All the outputs (s, f, t, ps, fc, tc) are vectors or matrices, we can set
% the number of dimensions to 2.
outAdaptor = setKnownSize(outAdaptor, [NaN NaN]);

% Now, update adaptors for the requested outputs.
for k = 1:nargout
    if k == 2 || k == 3
        % f and t are known to be column vectors for 'OutputTimeDimension'
        % set to 'downrows' (only option allowed for tall/spectrogram).
        vectorAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(outAdaptor.Class);
        varargout{k}.Adaptor = setKnownSize(vectorAdaptor, [NaN 1]);
    else
        varargout{k}.Adaptor = outAdaptor;
    end
end

