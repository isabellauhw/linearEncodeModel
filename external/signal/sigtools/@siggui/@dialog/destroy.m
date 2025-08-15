function destroy(hDlg)
%DESTROY Delete the dialog object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% Close the GUI.  This sets off 'unrender'.
close(hDlg);

% Destroy the reset transaction & the dialog listeners
delete(hDlg.Operations);

% In R13, replace with:
% super::destroy(hDlg);

delete(hDlg);

% [EOF]
