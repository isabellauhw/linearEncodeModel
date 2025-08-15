function render_controls(hEH)
%RENDER_CONTROLS Render the controls for the exportheader object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hFig = get(hEH, 'FigureHandle');
sz   = exportheader_gui_sizes(hEH);

% Render the variables component
hv = getcomponent(hEH, '-class', 'siggui.varsinheader');
render(hv, hFig, sz.variableframe);
set(hv, 'Visible', 'On');

% Render the datatype component
hdt = getcomponent(hEH, '-class', 'siggui.datatypeselector');
render(hdt, hFig, sz.datatype);
set(hdt, 'Visible', 'On');

% [EOF]
