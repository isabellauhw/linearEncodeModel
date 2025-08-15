function N = bpbsmodifyord(this,N)
%LPHPMODIFYORD   

%   Copyright 1999-2015 The MathWorks, Inc.


% For allpass structures, order must be twice an odd number
if rem(N,4) == 0, N = N + 2; end

% [EOF]
