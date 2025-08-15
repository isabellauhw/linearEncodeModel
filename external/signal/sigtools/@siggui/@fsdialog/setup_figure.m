function setup_figure(hFs)
%SETUP_FIGURE Setup the figure for the fsdialog

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

sz = fsdialog_gui_sizes(hFs);
bgc = get(0,'DefaultUicontrolBackgroundColor');

% Create a dialog
hFig = dialog('Name', 'Frequency Specifications', ...
    'Position', sz.figpos, ...
    'Visible', 'Off', ...
    'Color', bgc);

set(hFs, 'FigureHandle', hFig);

% [EOF]
