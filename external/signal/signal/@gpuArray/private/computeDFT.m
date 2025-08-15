function [Xx,f] = computeDFT(xin,nfft,varargin)
%COMPUTEDFT Computes DFT using FFT, CZT or Goertzel

%   [XX,F] = COMPUTEDFT(XIN,NFFT)
%   [XX,F] = COMPUTEDFT(XIN,F)
%   [XX,F] = COMPUTEDFT(...,Fs)

% Copyright 2019-2020 The MathWorks, Inc.

narginchk(2,3);
if nargin > 2
    Fs = varargin{1};
else
    Fs = 2*pi;
end

% Ensure xin is on the GPU
% Only send NFFT to GPU if it is non-scalar
xin = gpuArray(xin);

if isscalar(nfft)
    % If scalar, compute via FFT
    [Xx,f] = computeDFTviaFFT(xin,nfft,Fs);
else
    % If vector, then it contains a list of freqs. Compute via CZT or Goertzel
    % Move non-scalar NFFT to GPU
    nfft = gpuArray(nfft);
    f = reshape(nfft,[],1);
    
    % Check if uniformly spaced
    [~, ~, nF, maxerr] = signal.internal.spectral.getUniformApprox(f);
    isuniform = maxerr < 3*eps(signalwavelet.internal.typeof(f));
    
    % check if the number of steps in Goertzel ~  1 k1 N*M is greater
    % than the expected number of steps in CZT ~ 20 k2 N*log2(N+M-1)
    % where k2/k1 is empirically found to be ~80.
    n = size(xin,1);
    islarge = nF > 80*log2(nextpow2(nF+n-1));
    
    if isuniform && islarge
        % If equally spaced vector, compute via CZT
        Xx = computeDFTviaCZT(xin,f,Fs);
    else
        % If small number of bins or not uniformly spaced, use Goertzel
        Xx = computeDFTviaGoertzel(xin,f,Fs);
    end
    
end

end

%-------------------------------------------------------------------------
function [Xx,f] = computeDFTviaFFT(xin,nfft,Fs)

% Use FFT to compute raw STFT and return the F vector.

% Handle the case where NFFT is less than the segment length, i.e., "wrap"
% the data as appropriate.

nx = size(xin,1);

if nx > nfft
    xin = signal.internal.gpu.datawrap(xin,nfft);
    xin = reshape(xin,nfft,[]); % Converts 3D output of datawrap into to 2D
end

Xx = fft(xin,nfft);
f = cast(psdfreqvec('npts',nfft,'Fs',Fs), "like", nfft);

end

%--------------------------------------------------------------------------
function Xx = computeDFTviaGoertzel(xin,f,Fs)
% Use Goertzel to compute raw DFT

f = mod(f,Fs);    % 0 <= f < = Fs
xm = size(xin,1); % NFFT

% wavenumber in cycles/period used by the Goertzel function
k = cast(f/Fs*xm,signalwavelet.internal.typeof(xin));

Xx = goertzelImpl(xin,k);

end

%--------------------------------------------------------------------------
function Xx = computeDFTviaCZT(xin,f,Fs)
% Use CZT to compute raw DFT

npts = numel(f);

S.type = '()';
S.subs = {1};
fstart = subsref(f,S);

S.subs = {npts};
fstop = subsref(f,S);

% start with initial complex weight
Winit = exp(2i*pi*fstart/Fs);

% compute the relative complex weight
Wdelta = exp(2i*pi*(fstart-fstop)/((npts-1)*Fs));

% feed complex weights into chirp-z transform
Xx = czt(xin, npts, Wdelta, Winit);

end
