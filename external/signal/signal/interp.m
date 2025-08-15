function [odata,b] = interp(idata,r,n,cutoff)
%INTERP Resample data at a higher rate using lowpass interpolation.
%   Y = INTERP(X,R) resamples the sequence in vector X at R times
%   the original sample rate.  The resulting resampled vector Y is
%   R times longer, LENGTH(Y) = R*LENGTH(X).
%
%   A symmetric filter, B, allows the original data to pass through
%   unchanged and interpolates between so that the mean square error
%   between them and their ideal values is minimized.
%   Y = INTERP(X,R,N,CUTOFF) allows specification of arguments
%   N and CUTOFF which otherwise default to 4 and .5 respectively.
%   2*N is the number of original sample values used to perform the
%   interpolation.  For best results, use N no larger than 10.
%   The length of B is 2*N*R+1. The signal is assumed to be band
%   limited with cutoff frequency 0 < CUTOFF <= 1.0. 
%   [Y,B] = INTERP(X,R,N,CUTOFF) returns the coefficients of the
%   interpolation filter B.  
%
%   % Example:
%   %   Interpolate a signal by a factor of four.
%
%   t = 0:0.001:.029;                       % Time vector
%   x = sin(2*pi*30*t) + sin(2*pi*60*t);    % Original Signal
%   y = interp(x,4);                        % Interpolated Signal
%   subplot(211);
%   stem(x);
%   title('Original Signal');
%   subplot(212);
%   stem(y); 
%   title('Interpolated Signal');
%
%   See also DECIMATE, RESAMPLE, UPFIRDN.

%   Copyright 1988-2018 The MathWorks, Inc.

%   References:
%     "Programs for Digital Signal Processing", IEEE Press
%     John Wiley & Sons, 1979, Chap. 8.1.

if nargin < 3
   n = 4;
end
if nargin < 4
   cutoff = .5;
end

validateattributes(idata,{'single','double'},{'vector'},'interp','x');
validateattributes(r,{'numeric'},{'>=',1,'finite','integer','scalar'},'interp','r');
validateattributes(n,{'numeric'},{'>=',1,'finite','integer','scalar'},'interp','n');
validateattributes(cutoff,{'numeric'},{'>',0,'<=',1,'finite','scalar'},'interp','alpha');

%Convert all inputs to single or double based on the input type of the
%signal
if isa(idata,'single')
    r = single(r);
    n = single(n);
    cutoff = single(cutoff);
    cName = 'single';
else
    r = double(r);
    n = double(n);
    cutoff = double(cutoff);
    cName = 'double';
end
                      
if 2*n+1 > length(idata)
	s = int2str(2*n+1);
	error(message('signal:interp:InvalidDimensions', s));
end

% ALL occurrences of sin()/() are using the sinc function for the
% autocorrelation for the input data. They should all be changed
% consistently if they are changed at all.

% calculate AP and AM matrices for inversion
s1 = toeplitz(0:n-1) + eps;
s2 = hankel(2*n-1:-1:n);
s2p = hankel([1:n-1 0]);
s2 = s2 + eps + s2p(n:-1:1,n:-1:1);
s1 = sin(cutoff*pi*s1)./(cutoff*pi*s1);
s2 = sin(cutoff*pi*s2)./(cutoff*pi*s2);
ap = s1 + s2;
am = s1 - s2;

% Compute matrix inverses using Cholesky decomposition for more robustness
U = chol(ap);
ap = inv(U)*inv(U).';
U = chol(am);
am = inv(U)*inv(U).';

% now calculate D based on INV(AM) and INV(AP)
d = zeros(2*n,n,cName);
d(1:2:2*n-1,:) = ap + am;
d(2:2:2*n,:) = ap - am;

% set up arrays to calculate interpolating filter B
x = (0:r-1)/r;
y = zeros(2*n,1,cName);
y(1:2:2*n-1) = (n:-1:1);
y(2:2:2*n) = (n-1:-1:0);
X = ones(2*n,1,cName);
X(1:2:2*n-1) = -ones(n,1,cName);
XX = eps + y*ones(1,r,cName) + X*x;
y = X + y + eps;
h = .5*d'*(sin(pi*cutoff*XX)./(cutoff*pi*XX));
b = zeros(2*n*r+1,1,cName);
b(1:n*r) = h';
b(n*r+1) = .5*d(:,n)'*(sin(pi*cutoff*y)./(pi*cutoff*y));
b(n*r+2:2*n*r+1) = b(n*r:-1:1);

% use the filter B to perform the interpolation
[mm,mn] = size(idata);
nn = max([mm mn]);
if nn == mm
   odata = zeros(r*nn,1,cName);
else
   odata = zeros(1,r*nn,cName);
end
odata(1:r:nn*r) = idata;
% Filter a fabricated section of data first (match initial values and first derivatives by
% rotating the first data points by 180 degrees) to get guess of good initial conditions
% Filter length is 2*l*r+1 so need that many points; can't duplicate first point or
% guarantee a zero slope at beginning of sequence
od = zeros(2*n*r,1,cName);
od(1:r:(2*n*r)) = 2*idata(1)-idata((2*n+1):-1:2);
[od,zi] = filter(b,1,od); %#ok
[odata,zf] = filter(b,1,odata,zi);
odata(1:(nn-n)*r) = odata(n*r+1:nn*r);

% make sure right hand points of data have been correctly interpolated and get rid of
% transients by again matching end values and derivatives of the original data
if nn == mm
	od = zeros(2*n*r,1,cName);
else
	od = zeros(1,2*n*r,cName);
end
od(1:r:(2*n)*r) = 2*idata(nn)-(idata((nn-1):-1:(nn-2*n)));
od = filter(b,1,od,zf);
odata(nn*r-n*r+1:nn*r) = od(1:n*r);
