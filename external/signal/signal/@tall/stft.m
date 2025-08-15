function varargout = stft(x, varargin)
%STFT Short-time Fourier transform for tall arrays
%
%   S = STFT(X,'OutputTimeDimension',TIMEDIMENSION)
%   S = STFT(X,FS,'OutputTimeDimension',TIMEDIMENSION)
%   S = STFT(X,TS,'OutputTimeDimension',TIMEDIMENSION)
%   S = STFT(...,'Window',WINDOW)
%   S = STFT(...,'OverlapLength',NOVERLAP)
%   S = STFT(...,'FFTLength',NFFT)
%   S = STFT(...,'FrequencyRange',FREQRANGE)
%   [S,F,T] = STFT(...)
%
%   Limitations:
%   1. X must not be a tall row vector.
%   2. OutputTimeDimension must be always specified and set to 'downrows'.
%   3. Syntaxes with no output arguments are not supported.
%
%   See also STFT, ISTFT, TALL.

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(1, 12);
nargoutchk(0, 3);

if nargout == 0
    error(message('signal:tall:ZeroOutputArgsNotSupported', mfilename));
end

[x, sample, opts, isTimetableInput, isTypeUnknown] = iParseArguments(x, varargin{:});

% Compute Fs
if ~isTimetableInput
    % For numeric inputs, it is safe to take fs from opts.
    fs = opts.EffectiveFs;
else
    % Extract the first two rows of the timetable to lazily get the sample
    % rate.
    headX = head(x, 2);
    fs = clientfun(@(in) iGetFsFromHead(in), headX);
end

% Frequency vector f does not have the same height as S and t.
% matlab.tall.blockMovingWindow requires all the output arguments to have
% the same height. Lazily compute f separately as it can be defined by the
% FFT length and Fs.
import matlab.bigdata.internal.broadcast
f = clientfun(@(varargin) iCreateFrequencyVector(varargin{:}), x(1,:), broadcast(opts), broadcast(fs));

% Compute STFT with matlab.tall.blockMovingWindow
[varargout{1:nargout}] = iDoSTFTWithBlockMovingWindow(x, f, opts, fs, isTypeUnknown, sample, varargin{:});

% Extract some useful information known upfront to set the output adaptors.
[varargout{1:nargout}] = iSetOutputAdaptors(x, opts.Window, strcmpi(opts.TimeMode, 'ts'), varargout{:});

%--------------------------------------------------------------------------
function [x, sample, opts, isTimetableInput, isTypeUnknown] = iParseArguments(x, varargin)
% Parse input arguments of tall/stft using the same parser as in-memory
% STFT and a sample with fake data based on the tall input adaptor.

% Only input signal x can be tall
tall.checkIsTall(upper(mfilename), 0, x);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% x must be a tall column vector or a tall timetable
x = ensureTallColumnMatrixOrTimetable(x);

% Before validating input arguments with in-memory stft, we need to parse
% the window argument to specify the default input length of the sample.
% It must have length greater than or equal to the window length. Default
% window is a Hann window of length 128.
windowLength = 128;
if nargin > 2
    k = 1;
    while k < numel(varargin)
        % Loop through varargin to check if 'Window' name-value pair has
        % been specified
        currentArg = varargin{k};
        if (isStringScalar(currentArg) || ischar(currentArg)) ...
                && startsWith('Window', currentArg, 'IgnoreCase', true)
            win = varargin{k+1};
            % Get window and validate. Window must be a vector with a
            % window function.
            validateattributes(win, {'single', 'double'}, ...
                {'nonempty', 'finite', 'nonnan', 'vector', 'real'}, 'stft', 'Window');
            win = win(:);
            windowLength = length(win);
            validateattributes(windowLength, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative', 'real', 'nonnan', 'nonempty', ...
                'finite', '>', 1}, 'stft', 'WindowLength');
        end
        k = k + 1;
    end
end

% Build a sample based on the available metadata in the adaptor of x.
adaptor = matlab.bigdata.internal.adaptors.getAdaptor(x);
isTimetableInput = adaptor.Class == "timetable";
defaultSize = [windowLength 1];
defaultType = 'double';
if ~isTimetableInput
    sample = buildSample(adaptor, defaultType, defaultSize);
else
    % Build sample creates a timetable with repeated times and repeated
    % data. STFT requires uniformly increasing row times.
    varAdaptor = getVariableAdaptor(adaptor, 1);
    varType = varAdaptor.Class;
    if ~isempty(varType)
        % If the variable type is known, use it as default type for the
        % sample.
        defaultType = varType;
    end
    sample = buildSample(adaptor, defaultType, defaultSize);
    % buildSample method in TimetableAdaptor creates a timetable with
    % repeated data and repeated rowTimes. Create a fake uniformly
    % increasing row time vector assuming normalized frequencies to 1s.
    sample.Properties.RowTimes = sample.Properties.RowTimes + seconds((0:windowLength-1)');
end

% Call the in-memory STFT/ISTFT parser to get all the parsed arguments or
% default values in opts. It will also validate the input arguments as
% in-memory STFT.
% When using the arguments of opts, consider that EffectiveFs for
% timetables contains a wrong value. It has been defined with normalized
% frequencies for any input.
[~, opts] = signal.internal.stft.stftParser('stft', sample, varargin{:});

% For tall/stft, 'OutputTimeDimension' must be always set to 'downrows'.
ensureTallTimeDownrows(opts.TimeDimension, false);

% Determine if the output type is unknown because we do not know the type
% of x yet. If the input type is unknown but opts.IsSingle is true, then
% the ouptut type is single regardless the type of x.
isTypeUnknown = (isempty(adaptor.Class) && ~opts.IsSingle) ...
    || (isTimetableInput && isempty(varType) && ~opts.IsSingle);

%--------------------------------------------------------------------------
function fs = iGetFsFromHead(headX)
% Extract fs from first two rows of the timetable X
fs = 1;
if size(headX, 1) == 2
    fs = 1/seconds(headX.Properties.RowTimes(2) - headX.Properties.RowTimes(1));
end

%--------------------------------------------------------------------------
function f = iCreateFrequencyVector(~, opts, fs)
% Compute frequency vector from the number of bins of the FFT and Fs.
% Adjust accordingly if 'centered' is true or if input data is single.

if opts.IsNormalizedFreq
    fs = opts.EffectiveFs*pi;
end

switch opts.FreqRange
    case 'centered'
        f = psdfreqvec('npts', opts.FFTLength, 'Fs', fs, 'CenterDC', true);
    case 'twosided'
        f = psdfreqvec('npts', opts.FFTLength, 'Fs', fs, 'CenterDC', false);
    otherwise
        f = psdfreqvec('npts', opts.FFTLength, 'Fs', fs, 'Range', 'half');
end

if opts.IsSingle
    f = cast(f, 'single');
end

%--------------------------------------------------------------------------
function varargout = iDoSTFTWithBlockMovingWindow(x, f, opts, fs, isTypeUnknown, sample, varargin)
% Compute STFT with matlab.tall.blockMovingWindow.
% matlab.tall.blockMovingWindow calls in-memory STFT with blocks of the
% tall array that only contain full-size windows of data. It is expected
% that in-memory STFT will return as many rows as the number of windows in
% the given block.
% matlab.tall.blockMovingWindow requires: window length, stride, endPoints
% handling and outputsLike

% Define stride for matlab.tall.blockMovingWindow from windowLength and
% overlapLength.
windowLength = opts.WindowLength;
overlapLength = opts.OverlapLength;
stride = windowLength - overlapLength;

% Define outputsLike based on the different input types allowed by STFT. S
% is of the same type as x (double or single). If x is a timetable, S is of
% the same type as the variable in the timetable (double or single). S has
% the same number of columns as elements in the frequency vector f.
xLike = 1;
if opts.IsSingle
    xLike = single(xLike);
end
outputsLike = {xLike};

% t is of the same type of x except for the following cases:
% If x is a timetable, t is of the same type as the timetable row times.
% If the sampling time (ts) is given, t is a duration array.
tLike = [];
if nargout == 3
    if strcmpi(opts.TimeMode, 'tt')
        % Define outputsLike for t based on the timetable rowtimes, use
        % StartTime as a sample to get the type.
        tLike = sample.Properties.StartTime;
    elseif strcmpi(opts.TimeMode, 'ts') && nargout == 3
        % Use OutputsLike name-value pair to specify that t is a duration
        % array.
        tLike = duration(0, 0, 1, 'Format', opts.TimeUnits);
    else
        % Use OutputsLike to define a column vector of the same type as x.
        tLike = 1;
        if opts.IsSingle
            tLike = single(tLike);
        end
    end
    outputsLike = [outputsLike {tLike}];
end

% Define function handle for blockMovingWindow
stftFcn = @(info, x) iBlockSTFT(isTypeUnknown, x, varargin{:});

% Compute S (and t if requested) with matlab.tall.blockMovingWindow,
% EndPoints is set to 'discard'. STFT takes full-size windows and truncates
% the input signal when there are not enough samples to fill a complete
% window.
[out{1:max(1, nargout-1)}] = matlab.tall.blockMovingWindow([], stftFcn, ...
    windowLength, x, 'Stride', stride, 'EndPoints', 'discard', ...
    'OutputsLike', outputsLike);


% If the output type was unknown, we can now check the input type and cast
% S and t accordingly.
import matlab.bigdata.internal.broadcast
if isTypeUnknown
    isInputSingle = isaUnderlying(x, 'single');
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(x);
    if adaptor.Class == "timetable"
        isInputSingle = isaUnderlying(subsref(x, substruct('{}', {':', 1})), 'single');
    end
    isInputSingle = broadcast(isInputSingle);
    out{1} = slicefun(@(tf, x) iCastIfSingle(tf, x), isInputSingle, out{1});
    
    % We might need to cast to single if the input type was unknown and
    % tLike is double. If tLike was already set to datetime/duration, t is
    % a datetime/duration regardless the type of x.
    if nargout == 3 && isa(tLike, 'double')
        out{2} = slicefun(@(tf, x) iCastIfSingle(tf, x), isInputSingle, out{2});
    end
end

% If the data input has less time samples than the window length, stft
% throws an error. matlab.tall.blockMovingWindow does not call the block
% function for this case and returns an empy result. Check that it is not
% the case, tall/validateFalse or tall/validateTrue perform an elementfun
% operation and any of them requires an extra pass.
varargout{1} = tall.validateFalse(out{1}, isempty(out{1}), {'signal:stft:InvalidWindowLength', windowLength});

% If f is requested, place vector f in varargout (s, f, t)
if nargout > 1
    varargout = [varargout {f}];
    if isTypeUnknown
        varargout{2} = slicefun(@(tf, x) iCastIfSingle(tf, x), isInputSingle, f);
    end
    if nargout > 2
        varargout = [varargout out(2)];
    end
end

% If t is requested, it must be scaled up according to the number of blocks
% in the tall array.
if nargout > 2
    % t can be defined from stride, windowLength and fs.
    if opts.IsNormalizedFreq
        fs = 1;
    end
    
    % Extract the computed t for each block in the 3rd position of
    % varargout, scale all the blocks that are not the first one in the
    % tall array considering the number of existing samples before.
    oldT = varargout{3};
    paOldT = hGetValueImpl(oldT);
    partitionSizes = matlab.bigdata.internal.lazyeval.getPartitionSizes(paOldT);
    partitionSizes = matlab.bigdata.internal.broadcast(partitionSizes);
    paT = partitionfun(@(varargin) iScaleTimeVector(varargin{:}, stride, windowLength, opts.TimeUnits), ...
        partitionSizes, paOldT, broadcast(fs));
    adaptorT = matlab.bigdata.internal.adaptors.getAdaptor(oldT);
    varargout{3} = tall(paT, adaptorT);
    varargout{3} = copyPartitionIndependence(varargout{3}, oldT);
end

%--------------------------------------------------------------------------
function varargout = iBlockSTFT(isTypeUnknown, x, varargin)
% Compute STFT per block of the tall array using in-memory STFT.

isMultipleOutput = nargout > 1;
% If both S and t are requested, compute S, f, and t with in-memory stft.
[varargout{1:nargout + isMultipleOutput}] = stft(x, varargin{:});

% Do not return f. It has been previously computed.
if isMultipleOutput
    varargout(2) = [];
end

% If output type is unknown cast to double
if isTypeUnknown
    varargout{1} = double(varargout{1});
    if isMultipleOutput && isnumeric(varargout{2})
        % Cast t to double only if it is numeric, keep the type if it is a
        % duration/datetime array.
        varargout{2} = double(varargout{2});
    end
end

%--------------------------------------------------------------------------
function varargout = iCastIfSingle(tf, varargin)
% Cast to single if tf == true.
varargout = varargin;

if tf
    for k = 1:numel(varargout)
        varargout{k} = cast(varargout{k}, 'single');
    end
end

%--------------------------------------------------------------------------
function [isFinished, t] = iScaleTimeVector(info, partitionSizes, oldT, fs, stride, windowLength, timeUnits)
% Create time vector t considering the position of this block within the
% tall array.
isFinished = info.IsLastChunk;

t = oldT;
if ~isempty(oldT)
    initialPosition = sum(partitionSizes(1:info.PartitionId - 1)) + info.RelativeIndexInPartition;
    idx = initialPosition + (0:size(oldT, 1)-1).' - 1;
    t = ((idx.*stride) + windowLength/2)./fs;
    if isduration(oldT)
        t = duration(0, 0, t, 'Format', timeUnits);
    elseif isdatetime(oldT)
        oldT.Second = t;
        t = oldT;
    else
        t = cast(t, 'like', oldT);
    end
end

%--------------------------------------------------------------------------
function varargout = iSetOutputAdaptors(x, win, isTsProvided, varargin)
% Set the output adaptors with available information from the input signal
% and the window argument.

varargout = varargin;

inputAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(x);
% x can be a vector, matrix or timetable.
isTimetable = inputAdaptor.Class == "timetable";
if isTimetable
    xAdaptor = getVariableAdaptor(inputAdaptor, 1);
else
    xAdaptor = inputAdaptor;
end
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

% Set up the number of dimensions of the first output if we are know the
% number of channels in the input signal. This will be a matrix if the
% input signal is single-channel and will be a 3D array with as many pages
% as the number of columns in the multichannel signal.
if isTimetable
    if inputAdaptor.Size(2) > 1 && isKnownVector(xAdaptor)
        % Multichannel: x is a timetable with multiple variables and
        % each variable is a vector. S has as many pages as number of
        % variables in x.
        outAdaptor = setKnownSize(outAdaptor, [NaN NaN NaN]);
        outAdaptor = setSizeInDim(outAdaptor, 3, inputAdaptor.Size(2));
    elseif inputAdaptor.Size(2) == 1 && isKnownVector(xAdaptor)
        % Single-channel: x is a timetable with a single variable that is a
        % vector.
        outAdaptor = setKnownSize(outAdaptor, [NaN NaN]);
    elseif inputAdaptor.Size(2) == 1 && isKnownMatrix(xAdaptor)
        % Multichannel: x is a timetable with a single variable that is a
        % matrix. S has as many pages as columns in the variable in x.
        outAdaptor = setKnownSize(outAdaptor, [NaN NaN NaN]);
        outAdaptor = setSizeInDim(outAdaptor, 3, xAdaptor.Size(2));
    end
else
    if isKnownVector(xAdaptor)
        % Single-channel: x is a vector.
        outAdaptor = setKnownSize(outAdaptor, [NaN NaN]);
    elseif isKnownMatrix(xAdaptor)
        % Multichannel: x is a matrix. S has as many pages as columns in x.
        outAdaptor = setKnownSize(outAdaptor, [NaN NaN NaN]);
        outAdaptor = setSizeInDim(outAdaptor, 3, xAdaptor.Size(2));
    end
end

varargout{1}.Adaptor = outAdaptor;
% f and t are known to be column vectors for 'OutputTimeDimension' set to
% 'downrows' (only option allowed for tall/stft).
if nargout > 1
    % f is a column vector of the same type as outAdaptor.
    fAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(outAdaptor.Class);
    fAdaptor = setKnownSize(fAdaptor, [NaN 1]);
    varargout{2}.Adaptor = fAdaptor;
    if nargout > 2
        % t is a column vector but its type depends on the input type of x
        % and whether sample time Ts has been provided.
        if isTimetable
            % If x is a timetable, t is of the same type as row times in x.
            tAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(getDimensionNamesClass(inputAdaptor));
        elseif isTsProvided
            % If ts has been provided, t is a duration vector.
            tAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('duration');
        else
            % Otherwise, t is of the same type as S.
            tAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(outAdaptor.Class);
        end
        tAdaptor = setKnownSize(tAdaptor, [NaN 1]);
        varargout{3}.Adaptor = tAdaptor;
    end
end
