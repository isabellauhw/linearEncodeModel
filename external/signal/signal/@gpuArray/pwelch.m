function varargout = pwelch(x,varargin)
%PWELCH Power Spectral Density estimate via Welch's method on the GPU.
%
%   Pxx = PWELCH(X)
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
%   See also PWELCH, GPUARRAY.

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(1,9);
nargoutchk(0,3);

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

onGPU = false;
if nargin > 1
    % Both input signal and window (if it is a non-empty numeric vector)
    % determine whether the calculation is done on the GPU and the output
    % datatype.
    if isa(x, "gpuArray") || ( isa(varargin{1},"gpuArray") && isnumeric(varargin{1}) && numel(varargin{1})>1 )
        onGPU = true;
        % Ensure that the input signal is on the GPU.
        x = gpuArray(x);
        % Check that a window vector has been provided. If so, ensure that
        % it is on the GPU.
        if isnumeric(varargin{1}) && numel(varargin{1})>1
            varargin{1} = gpuArray(varargin{1});
        end
        % Gather all extra arguments.
        if nargin > 2
            [varargin{2:end}] = gather(varargin{2:end});
        end
    else
        % Gather all extra arguments.
        [varargin{:}] = gather(varargin{:});
    end
else
    if isa(x,"gpuArray")
        onGPU = true;
    end
end

% Dispatch in-memory pwelch if input signal is not gpuArray or input window
% vector is not gpuArray.
if ~onGPU
    varargout = cell(1,nargout);
    [varargout{:}] = pwelch(x,varargin{:});
    return;
end

% Look for psd, power, and ms window compensation flags.
[esttype, args] = signal.internal.psdesttype({'psd','power','ms'},'psd',varargin);
if strcmpi(esttype,'ms')
    error(message("signal:welch:InvalidMsLegacyOption","gpuArray"));
end
% Look for legacy freqrange options.
if any(strcmpi(args,'whole')) || any(strcmpi(args,'half'))
    error(message("signal:welch:InvalidFreqrangeLegacyOption","gpuArray"));
end

% Possible outputs are:
%       Plot
%       Pxx
%       Pxx, freq
%       Pxx, freq, Pxxc
welchOut = cell(1,nargout);
[welchOut{1:nargout}] = welch(x,esttype,args{:});
varargout = cellfun(@real,welchOut,"UniformOutput",false);

end