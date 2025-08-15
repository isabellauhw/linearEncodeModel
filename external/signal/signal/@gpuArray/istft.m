function varargout = istft(S,varargin)
%ISTFT Inverse short-time Fourier transform on the GPU.
%
%   X = ISTFT(S)
%   X = ISTFT(S,Fs)
%   X = ISTFT(S,Ts)
%   X = ISTFT(...,'Window',WINDOW)
%   X = ISTFT(...,'OverlapLength',NOVERLAP)
%   X = ISTFT(...,'FFTLength',NFFT)
%   X = ISTFT(...,'Method',METHOD)
%   X = ISTFT(...,'ConjugateSymmetric',CONJUGATESYMMETRIC)
%   X = ISTFT(...,'FrequencyRange',FREQRANGE)
%   X = ISTFT(...,'InputTimeDimension',TIMEDIMENSION)
%   [X,T] = ISTFT(...)
%
%   Limitations:
%   Unless 'ConjugateSymmetric' is set to true, the output X is always
%   complex even if all imaginary parts are zero.
%
%   See also GPUARRAY, ISTFT.

%   Copyright 2019-2020 The MathWorks, Inc.

%---------------------------------
% Check inputs/outputs
narginchk(1,16);
nargoutchk(0,2);

% Gather all extra arguments except Window. If Window has been provided as
% a gpuArray, also send the input stft S to the GPU.
if nargin > 1
    k = 1;
    while k <= numel(varargin)
        % Loop through varargin to check if 'Window' name-value pair has
        % been specified
        currentArg = varargin{k};
        if (isStringScalar(currentArg) || ischar(currentArg)) ...
                && startsWith('Window', currentArg, 'IgnoreCase', true)
            win = varargin{k+1};
            % Get window and validate. Window must be a vector with a
            % window function.
            validateattributes(win, {'single', 'double'}, ...
                {'nonempty', 'finite', 'nonnan', 'vector','real'}, 'istft', 'Window');
            win = win(:);
            windowLength = length(win);
            validateattributes(windowLength, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative', 'real', 'nonnan', 'nonempty', ...
                'finite', '>', 1}, 'istft', 'WindowLength');
            % This is a valid window, now check if it's a gpuArray and send
            % the input signal to the GPU.
            if isa(win, 'gpuArray')
                S = gpuArray(S);
            end
            k = k + 2;
        else
            varargin{k} = gather(currentArg);
            k = k + 1;
        end
    end
end

varargout = cell(1,max(1,nargout));

% Dispatch to in-memory ISTFT if the input stft S is not a gpuArray. It
% will already have been sent to the GPU if the window argument was on the
% GPU.
if ~isa(S, 'gpuArray')
    [varargout{:}] = istft(S,varargin{:});
    return;
end

%---------------------------------
% Parse inputs
[data,opts] = signal.internal.stft.stftParser('istft',S,varargin{:});

%---------------------------------
% Non-conjugate transpose if T-F map input does not have the default
% orientation
if strcmpi(opts.TimeDimension,'acrosscolumns')
    inputData = data;
else
    inputData = permute(data,[2,1,3]);
end

%---------------------------------
% Compute ISTFT
[varargout{:}] = computeISTFT(inputData,opts);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Helper functions
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [X,T] = computeISTFT(s,opts)
% Computes inverse short-time Fourier transform

% Set variables
win = opts.Window;
numCh = opts.NumChannels;
nwin = opts.WindowLength;
noverlap = opts.OverlapLength;
nfft = opts.FFTLength;
hop = nwin-noverlap;
nseg = opts.TimeAxisLength;
xlen = nwin + (nseg-1)*hop;
Fs = opts.EffectiveFs;

% format STFT to twosided
s = signal.internal.stft.formatISTFTInput(s,opts);

% IDFT
if opts.ConjugateSymmetric
    xifft = ifft(s,nfft,1,'symmetric');
else
    xifft = ifft(s,nfft,1,'nonsymmetric');
end

idx = gpuArray.colon(1,min(nwin,size(xifft,1)));
xifft = subsref(xifft,substruct('()',{idx,1:nseg,1:numCh}));

% Set method
if strcmpi(opts.Method,'ola')
    a = 0;
else % Else WOLA
    a = 1;
end

% Initialize window normalization values
winNominator = win.^a;
winDenominator = win.^(a+1);

% Overlap-add
% Get the indices for the recovered signal x
realOut = real(subsref(xifft, substruct('()', {[]})));
idxX = cast(gpuArray.colon(1,xlen)',"like",realOut);
% Get the indices that map the segment/window number to their position in
% the recovered signal x
mapFirstSegment = ones(nwin,1);
mapOtherSegments = repmat(2:nseg,hop,1);
idxY = cast([mapFirstSegment; mapOtherSegments(:)],"like",idxX);
% Get the indices for each channel
idxCh = cast(1:numCh,"like",idxX);

% Overlap-add for each element of the recovered signal x
[x, normVal] = arrayfun(@iOverlapAddElements, idxX, idxY, idxCh, noverlap, nwin, hop, nseg);

    function [x, normVal] = iOverlapAddElements(idxX, idxY, idxCh, noverlap, nwin, hop, nseg)
        % Identify the position of the first contribution within a segment
        % in the result of ifft(S)
        initialPositionOut = idxX+(idxY-1)*noverlap;
        
        % Current row in the resulting matrix of ifft(S)
        rowInS = initialPositionOut - (idxY-1)*nwin;
        
        % Initial value for recovered signal x obtained from up-level
        % variable xifft (ifft(S))
        x = xifft(rowInS, idxY, idxCh).*winNominator(rowInS);
        
        % Initial value for the normalization value
        normVal = winDenominator(rowInS);
        
        % Overlap-Add contributions from xifft
        maxContributions = min(floor((rowInS-1)/hop), nseg-idxY);
        for k = 1:maxContributions
            x = x + xifft(rowInS-k*hop, idxY+k, idxCh).*winNominator(rowInS-k*hop);
            normVal = normVal + winDenominator(rowInS-k*hop);
        end
    end

% Cast to appropriate complexity and type
outProto = subsref(s,substruct('()', {[]})); % s([])
if isreal(xifft)
    x = cast(x,'like',real(outProto));
else
    x = cast(x,'like',complex(outProto));
end

% Normalize
normVal = subsasgn(normVal, substruct('()', {normVal<(nseg*eps)}), 1);
X = squeeze(x)./normVal;

if nargout > 1
    % Time vector
    idx = gpuArray.colon(0,size(x,1)-1).';
    T = cast(idx./Fs,'like',real(outProto));
    
    % Scale time vector in the case of normalized frequency
    if opts.IsNormalizedFreq
        T = T.*opts.EffectiveFs; % sample
    end
    
    % Update time vector if a duration was provided
    if strcmpi(opts.TimeMode,'ts')
        T = seconds(gather(T));
        T.Format = opts.TimeUnits;
    end
end
end