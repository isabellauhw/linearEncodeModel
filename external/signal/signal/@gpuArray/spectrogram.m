function varargout = spectrogram(x,varargin)
%SPECTROGRAM Spectrogram using a Short-Time Fourier Transform (STFT) on the GPU.
%
%     S = SPECTROGRAM(X)
%     S = SPECTROGRAM(X,WINDOW)
%     S = SPECTROGRAM(X,WINDOW,NOVERLAP)
%     S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT)
%     S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT,Fs)
%     [S,F,T] = SPECTROGRAM(...)
%     [S,F,T] = SPECTROGRAM(X,WINDOW,NOVERLAP,F)
%     [S,F,T] = SPECTROGRAM(X,WINDOW,NOVERLAP,F,Fs)
%     [S,F,T,P] = SPECTROGRAM(...)
%     [S,F,T,P] = SPECTROGRAM(...,'MinThreshold',THRESH)
%     [S,F,T,P] = SPECTROGRAM(...,'reassigned')
%     [S,F,T,P,Fc,Tc] = SPECTROGRAM(...)
%     [...]  = SPECTROGRAM(...,SPECTRUMTYPE)
%     [...] = SPECTROGRAM(...,FREQRANGE)
%     [...] = SPECTROGRAM(...,'OutputTimeDimension',TIMEDIMENSION)
%     SPECTROGRAM(...)
%     SPECTROGRAM(...,FREQLOCATION)
%
%    See also: SPECTROGRAM

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(1,13);
nargoutchk(0,6);

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

onGPU = false;
if nargin > 1
    if nargin > 2
        varargin(2:end) = cellfun(@gather,varargin(2:end),'UniformOutput',false); % Gather all extra arguments
    end
    % Both X and WINDOW (if it is a vector) determine whether the calculation is done on the GPU
    if isa(x,"gpuArray") || ( isa(varargin{1},"gpuArray") && isnumeric(varargin{1}) && numel(varargin{1})>1 )
        x = gpuArray(x);
        if isnumeric(varargin{1}) % In case WINDOW not provided, this will be a name-value pair
            varargin{1} = gpuArray(varargin{1});
        end
        onGPU = true;
    else
        varargin = cellfun(@gather,varargin,'UniformOutput',false); % Gather all extra arguments
    end
else
    if isa(x,"gpuArray")
        onGPU = true;
    end
end

% Call Spectrogram on GPU if input signal (X) or WINDOW is gpuArray
if onGPU
    if nargout > 0
        [varargout{1:nargout}] = pspectrogram({x},'spect',varargin{:});
    else
        pspectrogram({x},'spect',varargin{:});
    end
else
    % Dispatch in-memory Spectrogram if input signal is not gpuArray
    if nargout > 0
        [varargout{1:nargout}] = spectrogram(x,varargin{:});
    else
        spectrogram(x,varargin{:});
    end
end

end