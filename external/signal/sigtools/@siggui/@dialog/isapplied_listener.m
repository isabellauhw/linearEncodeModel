function isapplied_listener(hDlg, eventData)
%ISAPPLIED_LISTENER Listener to the isApplied property

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

isApplied = get(hDlg, 'IsApplied');
h         = get(hDlg, 'DialogHandles');
enabState = get(hDlg, 'Enable');

% If the dialog has just been applied, reset the transaction and disable.
% the Apply button
if isApplied
    enabState = 'off';
end

set(h.apply,'Enable',enabState);

% [EOF]
