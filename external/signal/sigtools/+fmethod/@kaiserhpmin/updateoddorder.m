function N = updateoddorder(this,N)
%UPDATEODDORDER If order is odd, and gain is not zero at nyquist, increase
% the order by one. If MinOrder is even, then force to even.

%   Copyright 1999-2017 The MathWorks, Inc.

if isprop(this,'MinOrder') && strcmp(this.MinOrder,'even') && rem(N,2)
    N = N+1;
elseif rem(N,2)
    N = N+1;
end
% [EOF]
