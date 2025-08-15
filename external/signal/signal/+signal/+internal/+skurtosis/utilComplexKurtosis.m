function k = utilComplexKurtosis(x) %#codegen
%complexKurtosis computes the kurtosis of a complex signal x
% This function is only for internal use

%   Copyright 2017 The MathWorks, Inc.

x = x - mean(x);
s = mean(abs(x).^2);
k = mean(abs(x).^4)/s.^2 - 2;
end

