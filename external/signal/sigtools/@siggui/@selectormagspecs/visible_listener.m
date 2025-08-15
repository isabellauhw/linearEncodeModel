function visible_listener(h, eventData)
%VISIBLE_LISTENER  Listen to the visible state of the object

%   Author(s): Z. Mecklai
%   Copyright 1988-2017 The MathWorks, Inc.

% Determine the visible state
visState = get(h, 'Visible');

% Set the visibility of all uicontrols
set(handles2vector(h), 'Visible', visState);

% If the state was set to on update the uicontrols
if strcmpi(visState, 'on')
    update_uis(h);
end

% [EOF]
