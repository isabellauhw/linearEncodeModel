function g = czt(x, varargin)
%CZT  Chirp z-transform on the GPU
%   G = CZT(X, K, W, A)

%   Copyright 2019 The MathWorks, Inc.

narginchk(1,4);
if nargin > 1
    [varargin{:}] = gather(varargin{:});
end

if ~isa(x, "gpuArray")
    % Dispatch to CPU if X not gpuArray
    g = czt(x, varargin{:});
    return;
end

% Input can be a vector, matrix or a 3-D array
sz = size(x);
if length(sz) > 3
    error(message('signal:czt:InvalidBatchSignalDimension'))
end

if length(sz) == 3 && sz(1) == 1 && sz(2) == 1
    % Input is 1x1xK - to be treated as a vector of length K
    x = reshape(x,[],1);
    sz = size(x);
    thinArray = true;
else
    thinArray = false;
end

% Signal (X) is converted to a column vector on each page in InputParser so a transpose
% back would be required if it is a row vector
if sz(1) == 1
    transpose = true;
else
    transpose = false;
end

% Parsing Inputs
[x,k,w,a] = inputParser(x,varargin{:});
sz = size(x);
m = sz(1);

%------- Length for power-of-two fft.
nfft = 2^nextpow2(m+k-1);

%------- Premultiply data.
kk = gpuArray.colon((-m+1),max(k-1,m-1)).';
nn = gpuArray.colon(0,(m-1)).';

ww = arrayfun(@(w,kk) w^((kk^2)/2),w,kk);
S = substruct('()',{matlab.internal.ColonDescriptor(m,1,2*m-1)});
aa = arrayfun(@(ww,a,nn) ww*(a^-nn),subsref(ww,S),a,nn);

S.subs = {':',1};
y = x .* subsref(aa,S);

%------- Fast convolution via FFT.

fy = fft(y,nfft);

S = substruct('()',{matlab.internal.ColonDescriptor(1,1,k-1+m)});
fv = fft(1./subsref(ww,S),nfft);   % <----- Chirp filter.

S = substruct('()',{':',1});
fy = fy .* subsref(fv,S);
gg  = ifft(fy);

%------- Final multiply.
S = substruct('()',{matlab.internal.ColonDescriptor(m,1,m+k-1), 1});
S2 = substruct('()',{matlab.internal.ColonDescriptor(m,1,m+k-1), ':',':'});
g = subsref(gg,S2).* subsref(ww,S);

% Transpose if input signal (X) on each page wasn't a column vector
if transpose == true
    g = permute(g,[2,1,3:length(sz)]);
end

if thinArray
    g = reshape(g,1,1,[]);
end

end

function [x,k,w,a] = inputParser(x,varargin)

% Check Signal - This can only be Single or Double
if ~isfloat(x)
    error(message('signal:czt:InvalidSignal'))
end

sz = size(x);
if sz(1) == 1
    x = permute(x,[2,1,3:length(sz)]);
end

if nargin < 2
    k = max([sz(1),sz(2)]);
else
    k = double(varargin{1});
end

if nargin < 3
    w = exp(-1i.* 2.*pi./k);
else
    w = varargin{2};
end

if nargin < 4
    a = 1;
else
    a = varargin{3};
end

if any([size(k) size(w) size(a)]~=1)
    error(message('signal:czt:InvalidDimensions'))
end

% Signal (X), W and A determines type of output (G)
isSingle = isaUnderlying(x,'single') || isa(w,'single') || isa(a,'single');

% Cast all inputs to correct type
x = ensureFloatAndCast(x,isSingle,1);
if nargin > 1
    for ii = 1:nargin-1
        varargin{ii} = ensureFloatAndCast(varargin{ii},isSingle,ii+1);
    end
end

end

function x = ensureFloatAndCast(x,isSingle,inputNo)
% K,W,A must be numeric - but are cast to single/double depending on input
% Signal (X), W and A
if ~isnumeric(x)
    error(message('signal:czt:InvalidInput',inputNo))
end
if isSingle
    x = single(x);
else
    x = double(x);
end
end