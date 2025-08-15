function setunits(h, units)
%SETUNITS NO OP for abstractfiltertype's

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

G = findhandle(h,whichframes(h));
for i = 1:length(G)
    setunits(G(i),units);
end

% [EOF]
