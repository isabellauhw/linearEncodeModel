function visible_listener(this, eventData)
%VISIBLE_LISTENER Overload the siggui method to link the visible state of WVTool

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.

visState = get(this, 'Visible');

set(handles2vector(this), 'Visible', visState);

if strcmpi(visState, 'Off')
    set(allchild(this), 'Visible', 'Off');
end

updateparameter(this);

% [EOF]
