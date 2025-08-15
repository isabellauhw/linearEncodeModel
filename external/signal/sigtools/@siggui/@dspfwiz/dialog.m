function dialog(this)
%DIALOG Launch a dialog for the DSPFWIZ panel.

%   Copyright 2006-2011 The MathWorks, Inc.

if ~isrendered(this)

    sz = gui_sizes(this);
    
    % Create a figure for the export dialog.
    hFig = figure( ...
        'Visible', 'Off', ...
        'Resize', 'Off', ...
        'Tag',    'siggui.dspfwiz', ...
        'MenuBar', 'none', ...
        'HandleVisibility', 'callback', ...
        'IntegerHandle', 'off', ...
        'Color', get(0, 'DefaultUicontrolBackgroundColor'), ...
        'NumberTitle', 'off', ...
        'Position', [300 295 540 218]*sz.pixf);

    % Render the object to the figure.
    render(this, hFig, [5 5 535 210]*sz.pixf);

    % Center the figure on the screen.
    movegui(hFig, 'center');
    
    % Create listeners on the filter to update the dialog title and on this
    % object being destroyed so that we can clean up the dialog.
    l = [handle.listener(this, this.findprop('Filter'), 'PropertyPostSet', ...
        @(hp, ed) updateName(this)); ...
        handle.listener(this, 'ObjectBeingDestroyed', @(h, ed) delete(hFig));];
    setappdata(hFig, 'FilterListener', l);
    
    updateName(this);
end

set(this, 'Visible', 'On');
set(this.FigureHandle, 'Visible', 'On');

% -------------------------------------------------------------------------
function updateName(this)

hFig = get(this, 'FigureHandle');

set(hFig, 'Name', getString(message('signal:sigtools:siggui:ExportToSimulinkOrder1numberinteger', ...
    this.Filter.FilterStructure, order(this.Filter))));

% Also update the dialog in case there has been a change from single rate
% to multirate.
siggui_visible_listener(this);

% [EOF]
