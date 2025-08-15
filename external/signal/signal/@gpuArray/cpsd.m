function varargout = cpsd(x,y,varargin)
%CPSD Cross power spectral density estimate via Welch's method on GPU.
%
%   Pxy = CPSD(X,Y)
%   Pxy = CPSD(X,Y,WINDOW)
%   Pxy = CPSD(X,Y,WINDOW,NOVERLAP)
%   [Pxy,W] = CPSD(X,Y,WINDOW,NOVERLAP,NFFT)
%   [Pxy,W] = CPSD(X,Y,WINDOW,NOVERLAP,W)
%   [Pxy,F] = CPSD(X,Y,WINDOW,NOVERLAP,NFFT,Fs)
%   [Pxy,F] = CPSD(X,Y,WINDOW,NOVERLAP,F,Fs)
%   [...] = CPSD(...,'mimo')
%   [...] = CPSD(...,FREQRANGE)
%   CPSD(...)
%
%   See also CPSD, GPUARRAY.

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

% Dispatch in-memory cpsd if input signal is not gpuArray or input window
% vector is not gpuArray
if ~onGPU
    varargout = cell(1,nargout);
    [varargout{:}] = cpsd(x,y,varargin{:});
    return;
end

esttype = 'cpsd';
% Possible outputs are:
%       Plot
%       Pxy
%       Pxy, freq
[varargout{1:nargout}] = welch({x,y},esttype,varargin{:});
end