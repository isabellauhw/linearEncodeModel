function N = modifyord(this,N)
%MODIFYORD   

%   Copyright 1999-2015 The MathWorks, Inc.

% For allpass structures, order must be forced to the next odd number
N = lphpmodifyord(this,N);

% [EOF]
