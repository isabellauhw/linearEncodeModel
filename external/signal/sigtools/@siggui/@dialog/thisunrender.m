function thisunrender(hDlg)
%THISUNRENDER Unrender the dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

deletewarnings(hDlg);

hFig = get(hDlg, 'FigureHandle');
if ~isempty(hFig) & ishghandle(hFig)
    delete(hFig);
end

% [EOF]
