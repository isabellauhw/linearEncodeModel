function exporttarget_listener(hXP, eventData)
%EXPORTTARGET_LISTENER Listener to the exporttarget property

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

update_popup(hXP);
update_checkbox(hXP);
update_editboxes(hXP);

set(hXP, 'IsApplied', 0);

% [EOF]
