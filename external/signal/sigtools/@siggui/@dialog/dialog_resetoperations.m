function dialog_resetoperations(hDlg, varargin)
%DIALOG_RESETOPERATIONS Create a transaction in case of a cancel.
%   DIALOG_RESETOPERATIONS(hDLG) Create a transaction in case of a cancel.
%   This transaction will track all changes to the object and undo them if
%   the cancel button is selected.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This can be private

% setappdata(hDlg.FigureHandle, 'PreviousState', getstate(hDlg));

% Delete the old transactions
delete(hDlg.Operations);

% Create the transaction, ignore the isApplied property
hT(1) = sigdatatypes.transaction(hDlg, ...
    'isApplied', 'Enable', 'Visible', 'DialogHandles', varargin{:});

hChildren = allchild(hDlg);

for indx = 1:length(hChildren)
    hT(1+indx) = sigdatatypes.transaction(hChildren(indx));
end

set(hDlg,'Operations',hT);

% [EOF]
