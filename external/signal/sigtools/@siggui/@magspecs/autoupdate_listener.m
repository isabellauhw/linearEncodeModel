function autoupdate_listener(h, eventData)
%AUTOUPDATE_LISTENER updates the object to update freq values

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

state = get(eventData, 'NewValue');

hndls = get(h,'Handles');
handle = hndls.checkbox;

switch state
case 'on'
    set(handle,'Value',1)
case 'off'
    set(handle,'Value',0)
end

% [EOF]
