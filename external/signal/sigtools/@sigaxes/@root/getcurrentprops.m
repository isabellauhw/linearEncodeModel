function props = getcurrentprops(hObj)
%GETCURRENTPROPS Returns the props to set when the root is current.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

props = getdefaultprops(hObj);

if strcmpi(hObj.Enable, 'On')
    p = {'Color', 'g'};
else
    p = getdisabledprops(hObj);
end

props = {props{:}, 'LineWidth', 2, 'MarkerSize', 10, p{:}};

% [EOF]
