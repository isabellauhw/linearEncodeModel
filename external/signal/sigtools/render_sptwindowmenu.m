function hwindow = render_sptwindowmenu(hFig, pos)
%RENDER_SPTWINDOWMENU Render a Signal Processing Toolbox "Window" menu.
%   HWINDOW = RENDER_SPTWINDOWMENU(HFIG, POS) creates a "Window" menu in POS position
%   on a figure whose handle is HFIG and return the handles to all the menu items.

%   Author(s): V.Pellissier
%   Copyright 1988-2011 The MathWorks, Inc.

hwindow = matlab.ui.internal.createWinMenu(hFig);
set(hwindow,'Position',pos);

% [EOF]
