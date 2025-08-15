function varargout = getarguments(h, d)
%GETARGUMENTS

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

[F, A, W] = getNumericSpecs(h, d);

if nargout == 1
    varargout = {{F, A, W}};
else
    varargout = {F, A, W, {'hilbert'}};
end

% [EOF]
