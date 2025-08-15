function zi = ziexpand(Hd,x,zi)
%ZIEXPAND Expand initial conditions for multiple channels when necessary
%   ZI = ZIEXPAND(Hd, X, ZI) 
%
%   This function is intended to only be used by SUPER_FILTER to expand initial
%   conditions. 
%
%   This should be a private method.   

%   Author: R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.


narginchk(3,3);

[m,ndata] = size(x);
ndata = max(ndata,1);

if size(zi,2) ~= ndata && size(zi,2) ~= 1
	error(message('signal:dfilt:fftfir:ziexpand:InvalidDimensions'));
end

if size(zi,2) == 1
	zi = zi(:,ones(1,ndata));
end

% Expand the fftcoeffs as well
bfft = Hd.privfftcoeffs;
bfft = repmat(bfft(:,1),1,ndata);
Hd.privfftcoeffs = bfft;

