function ok(hDlg)
%OK The OK action for the Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% If the dialog is not applied, apply it.
if get(hDlg,'IsApplied')
    success = true;
else
    success = apply(hDlg);
end

if success
    set(hDlg, 'Visible', 'Off');
end

% [EOF]
