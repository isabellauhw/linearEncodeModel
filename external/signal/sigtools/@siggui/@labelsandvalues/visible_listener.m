function visible_listener(h, eventData)
%VISIBLE_LISTENER is the abstract class's implementation of the enable listener

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Get the vis state
visState = get(h, 'Visible');

if strcmp(visState, 'off')
    set(handles2vector(h), 'Visible', 'off');
else
    update_uis(h);
end

% [EOF]
