function name_listener(hDlg, hPrm)
%NAME_LISTENER Listener to the title property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

set(hDlg.FigureHandle, 'Name', hDlg.Name);

% [EOF]
