function y = rms(x, dim)
%RMS    Root mean squared value for tall arrays.
%   Y = RMS(X)
%   Y = RMS(X,DIM)
%
%   See also RMS, TALL.

%   Copyright 2017 The MathWorks, Inc.

if nargin==1
    y = sqrt(mean(x .* conj(x)));
else
    y = sqrt(mean(x .* conj(x), dim));
end

