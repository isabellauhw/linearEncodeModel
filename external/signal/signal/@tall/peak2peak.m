function y = peak2peak(x, dim)
%PEAK2PEAK Difference between largest and smallest component of a tall array.
%   Y = PEAK2PEAK(X)
%   Y = PEAK2PEAK(X,DIM)
%
%   See also PEAK2PEAK, TALL.

%   Copyright 2017 The MathWorks, Inc.

if nargin==1
    [s, l] = bounds(x);
else
    [s, l] = bounds(x, dim);
end
y = l - s;