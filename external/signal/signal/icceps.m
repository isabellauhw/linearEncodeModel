function x = icceps(xhat,nd)
%ICCEPS Inverse complex cepstrum.
%   ICCEPS(XHAT,ND) returns the inverse complex cepstrum of the real
%   sequence XHAT, removing ND samples of delay. If XHAT was obtained with
%   CCEPS(X), then the amount of delay that was added to X was the element
%   of round(unwrap(angle(fft(x)))/pi) corresponding to pi radians.
%
%   EXAMPLE: Use ICCEPS to compute the inverse complex cepstrum.
%   x = 1:10;
%   [xh,nd] = cceps(x);
%   % Use the delay parameter with icceps to invert the complex cepstrum
%   icceps(xh,nd)
%
%   See also CCEPS, RCEPS, HILBERT, and FFT.

%   Copyright 1988-2019 The MathWorks, Inc.

%   References:
%     [1] A.V. Oppenheim and R.W. Schafer, Digital Signal
%         Processing, Prentice-Hall, 1975.

%#codegen

narginchk(1,2);
% 'xhat' input must be a real, non-empty, non-sparse, vector
validateattributes(xhat,{'numeric'},{'nonempty','nonsparse','real','vector'},mfilename,'XHAT',1);
if nargin<2
    nd = 0;
end
% 'nd' input must be a real, non-empty, scalar, integer
validateattributes(nd,{'numeric'},{'nonempty','real','scalar','integer'},mfilename,'ND',2);
% Cast 'nd' to double to enforce precision rules
ndScalar = double(nd(1));

logh = fft(xhat(:),[],1);

% Add phase corresponding to integer lag
y = imag(logh);
n = length(y);
nh = fix((n+1)/2);
yLag = y + pi*ndScalar*(0:(n-1)).'/nh;

h = exp(complex(real(logh),yLag));
% Create uninitialized memory for 'x', the same size and class as xhat
x = coder.nullcopy(zeros(size(xhat),class(logh)));
x(:) = real(ifft(h,[],1));