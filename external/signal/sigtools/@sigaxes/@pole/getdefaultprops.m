function props = getdefaultprops(hObj)
%GETDEFAULTPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if strcmpi(hObj.Enable, 'On')
    p = {'Color', 'b'};
else
    p = getdisabledprops(hObj);
end

props = {'LineWidth', 1, 'Marker', 'x', 'MarkerSize', 8, 'LineStyle', 'none', p{:}};

% [EOF]
