function y = utilFilterDownSample(x, h, n) %#codegen
%filterDownSample Filter the signal x by h, and downsample it by n
% This function is only for internal use

%   Copyright 2017 The MathWorks, Inc.
N = length(x);
y = filter(h, 1, x);
y = y(n:n:N);
end