function updatecheckbox(hObj)
%UPDATECHECKBOX Update the checkbox

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(hObj, 'Handles');

enabState = get(hObj, 'Enable');
if strcmpi(enabState, 'on') & strcmpi(hObj.ExportMode, 'c header file')
    enabState = 'off';
end

set(h.check, 'Value', hObj.DisableWarnings, 'Enable', enabState);

% [EOF]
