function varargout = mscohere(x,y,varargin)
%MSCOHERE Magnitude squared coherence estimate via Welch's method on GPU.
%
%   Cxy = MSCOHERE(X,Y)
%   Cxy = MSCOHERE(X,Y,WINDOW)
%   Cxy = MSCOHERE(X,WINDOW,NOVERLAP)
%   [Cxy,W] = MSCOHERE(X,WINDOW,NOVERLAP,NFFT)
%   [Cxy,W] = MSCOHERE(X,WINDOW,NOVERLAP,W)
%   [Cxy,F] = MSCOHERE(X,WINDOW,NOVERLAP,NFFT,Fs)
%   [Cxy,F] = MSCOHERE(X,WINDOW,NOVERLAP,F,Fs)
%   [...] = MSCOHERE(...,'mimo')
%   [...] = MSCOHERE(...,FREQRANGE)
%   MSCOHERE(...)
%
%   See also MSCOHERE, GPUARRAY.

%   Copyright 2020 The MathWorks, Inc.

narginchk(2,8);
nargoutchk(0,2);

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

onGPU = false;
if nargin > 2
    % Both input signals and window (if it is a nonempty numeric vector)
    % determine whether the calculation is done on the GPU and the output
    % datatype
    if isa(x, "gpuArray") || isa(y,"gpuArray") || ( isa(varargin{1},"gpuArray") && isnumeric(varargin{1}) && numel(varargin{1})>1 )
        onGPU = true;
        % Ensure that the input signal is on the GPU
        x = gpuArray(x);
        y = gpuArray(y);
        % Check that a window vector has been provided. If so, ensure that
        % it is on the GPU
        if isnumeric(varargin{1}) && numel(varargin{1})>1
            varargin{1} = gpuArray(varargin{1});
        end
        % Gather all extra arguments
        if nargin > 3
            [varargin{2:end}] = gather(varargin{2:end});
        end
    else
        % Gather all extra arguments
        [varargin{:}] = gather(varargin{:});
    end
else
    if isa(x,"gpuArray") || isa(y,"gpuArray")
        onGPU = true;
        x = gpuArray(x);
        y = gpuArray(y);
    end
end

% Dispatch in-memory mscohere if input signal is not gpuArray or input window
% vector is not gpuArray
if ~onGPU
    varargout = cell(1,nargout);
    [varargout{:}] = mscohere(x,y,varargin{:});
    return;
end

esttype = 'mscohere';
% Possible outputs are:
%       Plot
%       Cxy
%       Cxy, freq
[varargout{1:nargout}] = welch({x,y},esttype,varargin{:});

if nargout == 0
    title(getString(message('signal:dspdata:dspdata:CoherenceTitle')));
    if any(strcmpi(varargin,'MIMO'))
        ylabel(getString(message('signal:dspdata:dspdata:MultipleCoherence')));  
    else
        ylabel(getString(message('signal:dspdata:dspdata:MagnitudeSquaredCoherence')));  
    end
end
end