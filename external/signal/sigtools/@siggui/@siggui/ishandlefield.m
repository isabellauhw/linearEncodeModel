function b = ishandlefield(hObj, field)
%ISHANDLEFIELD Returns true if the field is a handle

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.

h = get(hObj, 'Handles');

if isfield(h, field)
    h = convert2vector(h.(field));

    if all(ishghandle(h))
        b = true;
    else
        b = false;
    end
else
    b = false;
end

% [EOF]
