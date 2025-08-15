function g = czt(x, k, w, a)
%CZT  Chirp Z-transform.
%   G = CZT(X, M, W, A) is the M-element Z-transform of sequence X,
%   where M, W and A are scalars which specify the contour in the z-plane
%   on which the Z-transform is computed.  M is the length of the transform,
%   W is the complex ratio between points on the contour, and A is the
%   complex starting point.  More explicitly, the contour in the z-plane
%   (a spiral or "chirp" contour) is described by
%       z = A * W.^(-(0:M-1))
%
%   The parameters M, W, and A are optional; their default values are
%   M = length(X), W = exp(-1j*2*pi/M), and A = 1.  These defaults
%   cause CZT to return the Z-transform of X at equally spaced points
%   around the unit circle, equivalent to FFT(X).
%
%   If X is a matrix, the chirp Z-transform operation is applied to each
%   column. If X is a 3-D array, then CZT(X) treats the values along the
%   first array dimension whose size does not equal 1 as vectors and
%   returns the Z-transform of each vector.
%
%   % Example:
%
%   %   Use czt to zoom in on a narrowband section of a bandstop filter
%   %   response
%
%   % Design filter
%
%   h = fir1(62,[0.3 0.5],'stop',rectwin(63));
%
%   % Compute CZT
%
%   f1 = 0.2;
%   f2 = 0.7;
%
%   m = 1024;
%   w = exp(-1j*pi*(f2-f1)/m);
%   a = exp(1j*pi*f1);
%
%   z = czt(h,m,w,a);
%
%   % Compute FFT and compare to CZT
%
%   y = fft(h,2*m);
%
%   fm = (0:m-1)/m;
%   plot(fm,abs(y(1:m)),fm*(f2-f1)+f1,abs(z))
%   legend('FFT','CZT')
%
%   See also FFT, FREQZ.

%   Copyright 1988-2019 The MathWorks, Inc.

%   References:
%     [1] Oppenheim, Alan V., and Ronald W. Schafer. Discrete-Time Signal
%         Processing. 3rd ed. Upper Saddle River, NJ: Pearson, 2010.
%     [2] Rabiner, Lawrence R., and Bernard Gold. Theory and Application
%         of Digital Signal Processing. Englewood Cliffs, NJ:
%         Prentice-Hall, 1975.

sz = size(x);
oldm = sz(1);

if length(sz) > 3
    error(message('signal:czt:InvalidBatchSignalDimension'))
end

if length(sz) == 3 && sz(1) == 1 && sz(2) == 1
    % Input is 1x1xK
    x = reshape(x,numel(x),1);
    sz = size(x);
    thinArray = true;
else
    thinArray = false;
end

if sz(1) == 1
    x = permute(x,[2,1,3:length(sz)]);
    sz = size(x);
end

m = sz(1);
n = sz(2);

if nargin < 2
    k = max([m,n]);
end

if nargin < 3
    % M cast to double to enforce precision rules
    Mtmp = signal.internal.sigcasttofloat(k,'double','czt','M','allownumeric');
    w = exp(-1i .* 2 .* pi ./ Mtmp);
end

if nargin < 4
    a = 1;
end

% Checks if 'X', 'W' and 'A' are valid numeric data inputs
signal.internal.sigcheckfloattype(x,'','czt','X');
signal.internal.sigcheckfloattype(w,'','czt','W');
signal.internal.sigcheckfloattype(a,'','czt','A');

% Cast to enforce precision rules
k = signal.internal.sigcasttofloat(k,'double','czt','M','allownumeric');

if any([size(k) size(w) size(a)]~=1)
    error(message('signal:czt:InvalidDimensions'))
end

%------- Length for power-of-two fft.

nfft = 2^nextpow2(m+k-1);

%------- Premultiply data.

kk = ( (-m+1):max(k-1,m-1) ).';
kk2 = (kk .^ 2) ./ 2;
ww = w .^ (kk2);   % <----- Chirp filter is 1./ww
nn = (0:(m-1))';
aa = a .^ ( -nn );
aa = aa.*ww(m+nn);
y = x .* aa(:,ones(1,n));

%------- Fast convolution via FFT.

fy = fft(  y, nfft );
fv = fft( 1 ./ ww(1:(k-1+m)), nfft );   % <----- Chirp filter.
fy = fy .* fv(:,ones(1, n));
g  = ifft( fy );

%------- Final multiply.
g = g( m:(m+k-1), :, :) .* ww( m:(m+k-1),ones(1, n) );
gSize = size(g);
g = reshape(g,[gSize(1),gSize(2),sz(3:length(sz))]);
if oldm == 1
    g = permute(g,[2,1,3:length(sz)]);
end
if thinArray
    g = reshape(g,[1,1,numel(g)]);
end