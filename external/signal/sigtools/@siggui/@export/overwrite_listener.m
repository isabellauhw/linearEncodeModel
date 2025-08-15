function overwrite_listener(hXP, eventData)
%OVERWRITE_LISTENER Listener to the Overwrite property of the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% This is a WhenRenderedListener

% Sync the check box and the property
update_checkbox(hXP)

set(hXP, 'isApplied', 0);

% [EOF]