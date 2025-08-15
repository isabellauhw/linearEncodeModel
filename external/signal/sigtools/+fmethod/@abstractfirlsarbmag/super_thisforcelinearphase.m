function b = super_thisforcelinearphase(this,b)
%SUPER_THISFORCELINEARPHASE   

%   Copyright 1999-2017 The MathWorks, Inc.

N = length(b);
isodd = rem(N,2);

% Determine symmetry
tol = 1e-3;
if max(abs(b - conj(b(end:-1:1)))) <= tol
    issym = true;
elseif max(abs(b + conj(b(end:-1:1)))) <= tol
    issym = false;
else
    return
end

if isodd
    if issym
        b((N+1)/2+1:N) = conj(b((N-1)/2:-1:1));
    else
        b((N+1)/2+1:N) = -conj(b((N-1)/2:-1:1));
    end
else
    if issym
        b(N/2+1:N) = conj(b(N/2:-1:1));
    else
        b(N/2+1:N) = -conj(b(N/2:-1:1));
    end
end

% [EOF]
