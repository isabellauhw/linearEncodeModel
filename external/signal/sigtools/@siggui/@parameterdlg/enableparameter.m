function enableparameter(hDlg, tag)
%ENABLEPARAMETER Enable a parameter on the parameter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

dparams = get(hDlg, 'DisabledParameters');

indx = find(strcmpi(tag, dparams));

if ~isempty(indx)
    dparams(indx) = [];
end

set(hDlg, 'DisabledParameters', dparams);

% [EOF]
