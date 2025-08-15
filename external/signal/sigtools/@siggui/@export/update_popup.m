function update_popup(hXP)
%UPDATE_POPUP Update the Export Popup

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This can be a private method

h       = get(hXP,'Handles');
eTarget = get(hXP,'ExportTarget');

targets = get(h.popup,'String');

indx = strmatch(eTarget, targets);

set(h.popup, 'Value', indx);

enabState = get(hXP, 'Enable');

% Make sure the enabState of the editboxes is correct
if strcmpi(enabState, 'On')
    
    switch eTarget
    case 'Workspace'
        checkEnabState = 'On';
        editEnabState  = 'On';
    case 'MAT-file'
        checkEnabState = 'Off';
        editEnabState  = 'On';
    otherwise
        checkEnabState = 'Off';
        editEnabState  = 'Off';
    end
else
    checkEnabState = 'Off';
    editEnabState  = 'Off';
end

setenableprop(h.edit(ishghandle(h.edit)), editEnabState);
setenableprop(h.labels(ishghandle(h.labels)), editEnabState);

set(h.checkbox,'Enable', checkEnabState);

% [EOF]
