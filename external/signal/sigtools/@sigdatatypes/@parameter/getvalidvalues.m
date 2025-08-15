function out = getvalidvalues(hObj, out)
%GETVALIDVALUES Returns the valid values

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if iscell(out)
    out     = get(hObj, 'AllOptions');
    do      = get(hObj, 'DisabledOptions');
    out(do) = [];
end

% [EOF]
