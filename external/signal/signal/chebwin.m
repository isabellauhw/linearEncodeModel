function w = chebwin(n, r)
%CHEBWIN Chebyshev window.
%   CHEBWIN(N) returns an N-point Chebyshev window in a column vector.
%
%   CHEBWIN(N,R) returns the N-point Chebyshev window with R decibels of
%   relative sidelobe attenuation. If omitted, R is set to 100 decibels.
%
%   % Example:
%   %   Create a 64-point Chebyshev window with 100 dB of sidelobe
%   %   attenuation and display the result using WVTool.
%
%   L=64;
%   wvtool(chebwin(L))
%
%   See also TAYLORWIN, GAUSSWIN, KAISER, TUKEYWIN, WINDOW.

%   Author: James Montanaro
%   Reference: E. Brigham, "The Fast Fourier Transform and its Applications"

%   Copyright 1988-2019 The MathWorks, Inc.
narginchk(1,2);

% Default value for R parameter.
if nargin < 2
    rVal = 100.0;
elseif isempty(r)
    rVal = cast(100.0,class(r));
else
    rVal = r;
end
validateattributes(rVal,{'numeric'},{'real','scalar','nonnegative'},mfilename,'r',2);           % 'r' input must be a real non-negative scalar
% Cast to enforce precision rules.
rScalar = double(rVal(1));

if isempty(n)
    w = zeros(0,1);
    return
else
    validateattributes(n,{'numeric'},{'real','scalar','finite','nonnegative'},mfilename,'n',1);	% 'n' input must be real finite scalar
    nScalar = double(n(1));
    
    if nScalar == 0
        w = zeros(0,1);
        return
    elseif nScalar == 1
        w = 1;
        return
    else
        % Check if order is already an integer If not, round to nearest
        % integer.
        if nScalar ~= floor(nScalar)
            nScalar = round(nScalar);
            coder.internal.warning('signal:chebwin:InvalidOrderRounding');
        end
        w = chebwinx(nScalar,rScalar);
    end
end
end