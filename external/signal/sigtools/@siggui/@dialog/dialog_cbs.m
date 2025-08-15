function cbs = dialog_cbs(hDlg)
%DIALOG_CBS Callbacks for the dialog buttons

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

cbs        = siggui_cbs(hDlg);
cbs.ok     = {cbs.method, hDlg, 'ok'};
cbs.cancel = {cbs.method, hDlg, 'cancel'};
cbs.apply  = {cbs.method, hDlg, 'apply'};

% [EOF]
