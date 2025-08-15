function deletewarnings(hDlg)
%DELETEWARNINGS Delete warnings for the dialog

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.

% This should be a private method

h = get(hDlg, 'DialogHandles');
if isfield(h, 'warn')
    delete(h.warn(ishghandle(h.warn)));
end
h.warn = [];
set(hDlg, 'DialogHandles', h);

% [EOF]