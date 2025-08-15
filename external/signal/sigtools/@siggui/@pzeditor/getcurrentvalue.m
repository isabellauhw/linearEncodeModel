function cv = getcurrentvalue(hObj)
%GETCURRENTVALUE Get the value of the selected pole zero

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hc = get(hObj, 'CurrentRoots');
if isempty(hc)
    cv = [];
else
    cv = double(hc);
end

% [EOF]
