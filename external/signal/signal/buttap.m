function [z,p,k] = buttap(n) %#codegen
%BUTTAP Butterworth analog lowpass filter prototype.
%   [Z,P,K] = BUTTAP(N) returns the zeros, poles, and gain
%   for an N-th order normalized prototype Butterworth analog
%   lowpass filter.  The resulting filter has N poles around
%   the unit circle in the left half plane, and no zeros.
%
%   % Example:
%   %   Design a 9th order Butterworth analog lowpass filter and display
%   %   its frequency response.
%
%   [z,p,k]=buttap(9);          % Butterworth filter prototype
%   [num,den]=zp2tf(z,p,k);     % Convert to transfer function form
%   freqs(num,den)              % Frequency response of analog filter          
%
%   See also BUTTER, CHEB1AP, CHEB2AP, ELLIPAP.

%   Author(s): J.N. Little and J.O. Smith, 1-14-87
%   	   L. Shure, 1-13-88, revised
%   Copyright 1988-2018 The MathWorks, Inc.

narginchk(1,1);
nargoutchk(0,3);

validateattributes(n,{'numeric'},{'scalar','integer','positive'},'buttap','order');

% Cast to enforce precision rules
n = signal.internal.sigcasttofloat(n(1),'double','buttap','n','allownumeric');

% Poles are on the unit circle in the left-half plane.
z = [];

% Poles are on the unit circle in the left-half plane.
 ptemp = exp(1i*(pi*(1:2:n-1)./(2*n) + pi/2));
 
 if coder.target('MATLAB')
    len = length(ptemp);
 else
    len = coder.internal.indexInt(length(ptemp));
 end

 if isodd(n) % n is odd
     p = coder.nullcopy(complex(zeros(2*len+1,1),1));
     p(end) = -1;
 else
     p = coder.nullcopy(complex(zeros(2*len,1),1));
 end

 for k = 1:len
     p(2*k-1) = ptemp(k);
     p(2*k) = conj(ptemp(k));
 end

k = real(prod(-p));

end

