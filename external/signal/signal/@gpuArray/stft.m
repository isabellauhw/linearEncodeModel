function varargout = stft(x,varargin)
%STFT Short-time Fourier transform on the GPU.
%
%   S = STFT(X)
%   S = STFT(X,FS)
%   S = STFT(X,TS)
%   S = STFT(...,'Window',WINDOW)
%   S = STFT(...,'OverlapLength',NOVERLAP)
%   S = STFT(...,'FFTLength',NFFT)
%   S = STFT(...,'FrequencyRange',FREQRANGE)
%   S = STFT(...,'OutputTimeDimension',TIMEDIMENSION)
%   [S,F,T] = STFT(...)
%
%   See also STFT, ISTFT, GPUARRAY.

%   Copyright 2019-2020 The MathWorks, Inc.

%---------------------------------
% Check inputs/outputs
narginchk(1,12);
nargoutchk(0,3);

% Gather all extra arguments except Window. If Window has been provided as
% a gpuArray, also send the input signal X to the GPU.
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
                {'nonempty', 'finite', 'nonnan', 'vector','real'}, 'stft', 'Window');
            win = win(:);
            windowLength = length(win);
            validateattributes(windowLength, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative', 'real', 'nonnan', 'nonempty', ...
                'finite', '>', 1}, 'stft', 'WindowLength');
            % This is a valid window, now check if it's a gpuArray and send
            % the input signal to the GPU.
            if isa(win, 'gpuArray')
                x = gpuArray(x);
            end
            k = k + 2;
        else
            varargin{k} = gather(currentArg);
            k = k + 1;
        end
    end
end

% Dispatch to in-memory STFT if the input signal X is not a gpuArray. It
% will already have been sent to the GPU if the window argument was on the
% GPU.
if ~isa(x, 'gpuArray')
    if nargout > 0
        [varargout{1:nargout}] = stft(x,varargin{:});
    else
        stft(x,varargin{:});
    end
    return;
end

%---------------------------------
% Parse inputs
[data,opts] = signal.internal.stft.stftParser('stft',x,varargin{:});

% No convenience plot for multichannel signals
if nargout == 0 && (opts.NumChannels >1)
    error(message('signal:stft:InvalidNumOutputMultiChannel'));
end

%---------------------------------
% Compute STFT
[S,F,T] = computeSTFT(data,opts);

%---------------------------------
% Set outputs

% Convenience plot
if nargout==0
    % Gather all outputs for convenience plot
    signal.internal.stft.displaySTFT(gather(T),gather(F),gather(S),opts);
end

% Set varargout
if nargout >= 1
    if strcmp(opts.TimeDimension,'downrows')
        % Non-conjugate transpose S.
        varargout{1} = permute(S,[2,1,3]);
    else
        varargout{1} = S;
    end
end

if nargout >= 2
    if opts.IsNormalizedFreq
        varargout{2} = F.*pi; % rad/sample
    else
        varargout{2} = F;
    end
end

if nargout == 3
    if isnumeric(T) && ~isempty(opts.TimeUnits)
        T = duration(0,0,gather(T),'Format',opts.TimeUnits);
    end
    % Ensure time output is a column vector
    varargout{3} = subsref(T, substruct('()', {':'}));
end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Helper functions
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [S,F,T] = computeSTFT(x,opts)
% Computes the short-time Fourier transform

% Set variables
win = opts.Window;
nwin = opts.WindowLength;
noverlap = opts.OverlapLength;
nfft = opts.FFTLength;
Fs = opts.EffectiveFs;

% Place x into columns and return the corresponding central time estimates
[xin,T] = parallel.internal.gpu.extractWindows(x,nwin,noverlap,Fs);

% Apply the window to the array of offset signal segments and perform a DFT
xinoff = win.*xin;
[S,f] = computeDFT(xinoff,nfft,Fs);

% Outputs format ('centered', 'onesided', 'twosided')
[S,f] = signal.internal.stft.formatSTFTOutput(S,f,opts);

% Scale frequency and time vectors in the case of normalized frequency
if opts.IsNormalizedFreq
    T = T.*opts.EffectiveFs; % samples
end

% Set outputs
realX = real(subsref(x, substruct('()', {[]})));
F = cast(f,'like',realX);
end