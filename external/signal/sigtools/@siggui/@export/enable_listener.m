function enable_listener(hXP, eventData)
%ENABLE_LISTENER Listener to the enable property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

dialog_enable_listener(hXP, eventData);

% UPDATE_POPUP sets the enable prop of the edit boxes
update_popup(hXP);

% [EOF]
