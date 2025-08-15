function setup_figure(hDlg)
%SETUP_FIGURE Setup a default dialog.  This method must be overloaded.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

% This can be a private method

disp('The SETUP_FIGURE method must be overloaded!');

visState = get(hDlg, 'Visible');
cbs      = dialog_cbs(hDlg);

% Set up a default figure so that the RENDER method won't error,
% but still tell the developer to create his own setup_figure
hFig = figure('Position',[500 500 205 200], ...
    'MenuBar','None', ...
    'Resize','Off', ...
    'Visible',visState, ...
    'NumberTitle','Off', ...
    'Name','Dialog', ...
    'IntegerHandle','Off', ...
    'HandleVisibility', 'Off', ...
    'CloseRequestFcn',cbs.cancel);

set(hDlg, 'FigureHandle', hFig);

% [EOF]
