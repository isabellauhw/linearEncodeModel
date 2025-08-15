function render_controls(this)
%RENDER_CONTROLS Render the controls

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

hFig = get(this, 'FigureHandle');
sz   = exportheader_gui_sizes(this);

% Render the variables component
hvh = getcomponent(this, '-class', 'siggui.varsinheader');
render(hvh, hFig, sz.variableframe);

% Render the datatype component
hdt = getcomponent(this, '-class', 'siggui.datatypeselector');
render(hdt, hFig, sz.datatype);

hts = getcomponent(this, '-class', 'siggui.targetselector');
render(hts, hFig, sz.targetselect);

% Make these visible here since the dialog does not handle this.
set([hts hdt hvh], 'Visible', 'On');

render_mode_frame(this);

updatecheckbox(this);

attachlisteners(this);


% -----------------------------------------------------------
function attachlisteners(h)

listener = [ ...
        handle.listener(h, h.findprop('ExportMode'), ...
        'PropertyPostSet', @exportmode_listener); ...
        handle.listener(h, h.findprop('DisableWarnings'), ...
        'PropertyPostSet', @disablewarnings_listener); ...
    ];

set(listener, 'CallbackTarget', h);

set(h, 'WhenRenderedListeners', listener);


% -----------------------------------------------------------
function render_mode_frame(this)

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = exportheader_gui_sizes(this);
cbs  = callbacks(this);

h.frame = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', sz.exportmode);

lblstr = getString(message('signal:sigtools:siggui:Exportmode'));

lblpos = [sz.exportmode(1)+sz.hfus ...
        sz.exportmode(2) + (sz.exportmode(4) - sz.uh)/2 ...
        largestuiwidth({lblstr}) ...
        sz.uh];

h.lbl   = uicontrol(hFig, ...
    'Style', 'Text', ...
    'Position', lblpos, ...
    'String', lblstr);

popStrs = set(this, 'ExportMode');
popPos  = [lblpos(1)+lblpos(3)+sz.uuhs ...
        lblpos(2) + sz.lblTweak ...
        largestuiwidth(popStrs) + sz.popwTweak ...
        sz.uh];

h.popup = uicontrol(hFig, ...
    'Style', 'Popup', ...
    'String', getTranslatedStringcell('signal:sigtools:siggui',popStrs), ...
    'Position', popPos, ...
    'BackgroundColor', 'w', ...
    'Callback', {cbs.popup, this});

radiostr = getString(message('signal:sigtools:siggui:DisableMemoryTransferWarnings'));
radiopos = [popPos(1) + popPos(3) + sz.uuhs ...
        lblpos(2) ...
        largestuiwidth({radiostr}) + sz.rbwTweak ...
        sz.uh];

h.check = uicontrol(hFig, ...
    'Style', 'Check', ...
    'String', radiostr, ...
    'Position', radiopos, ...
    'Value', this.DisableWarnings, ...
    'Callback', {cbs.check, this});

set(this, 'Handles', h);

exportmode_listener(this);

% [EOF]
