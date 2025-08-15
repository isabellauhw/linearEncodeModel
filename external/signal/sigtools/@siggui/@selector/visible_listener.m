function visible_listener(hObj, varargin)
%VISIBLE_LISTENER   Listener to the Visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

sigcontainer_visible_listener(hObj, varargin{:});

h = get(hObj, 'Handles');
strs = get(hObj, 'Strings');

for indx = 1:length(strs)
    if iscell(strs{indx})
        set(h.popup(indx), 'Visible', hObj.Visible);
    else
        set(h.popup(indx), 'Visible', 'Off');
    end
end

% [EOF]
