function s = coeffs(this)
%COEFFS   Return the coefficients in a structure.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.

N = length(this);

if N==1
    s = thiscoeffs(this);
else
    % Build a structure with field names equal to the coefficient names.
    for indx = 1:N
        s{indx} = thiscoeffs(this(indx));
    end
end

% [EOF]
