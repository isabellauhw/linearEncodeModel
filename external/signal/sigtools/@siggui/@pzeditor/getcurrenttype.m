function type = getcurrenttype(hObj)
%GETCURRENTTYPE Get the type of the current pole/zero

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hPZ  = get(hObj, 'CurrentRoots');

if ~isempty(hPZ)
    type = gettype(hObj.CurrentRoots);
else
    type = '';
end

% [EOF]
