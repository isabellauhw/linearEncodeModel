function N = lphpmodifyord(this,N)
%LPHPMODIFYORD   

%   Copyright 1999-2015 The MathWorks, Inc.


% For allpass structures, order must be odd
if rem(N,2) == 0, N = N + 1; end

% [EOF]
