function renderactionbtn2(this, row, col, str, method, varargin)
%RENDERACTIONBTN2   Render the gui's action button
%   RENDERACTIONBTN2(THIS, POS, STR, METHOD) Render the GUI's action
%   button to the center of POS with the label STR.  It will call the
%   method METHOD (string or function handle) via the method_cb of
%   SIGGUI_CBS.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(4,5);

sz  = gui_sizes(this);
cbs = siggui_cbs(this);

if ischar(method), field = lower(method);
else,              field = lower(func2str(method)); end

tag = [get(classhandle(this), 'Name') '_' field];

hPanel  = get(this, 'Container');
hLayout = get(this, 'Layout');
if isempty(hLayout)
    hLayout = siglayout.gridbaglayout(hPanel);
    set(this, 'Layout', hLayout);
end

h = get(this, 'Handles');

h.(field) = uicontrol(hPanel, ...
    'String', getTranslatedString('sigtools/@siggui/@siggui/renderactionbtn2',str) , ...
    'Style', 'PushButton', ...
    'HorizontalAlignment', 'Center', ...
    'Tag', tag, ...
    'Callback', {cbs.method, this, method, varargin{:}});

set(this, 'Handles', h);

hLayout.add(h.(field), row, col, ...
    'MinimumHeight', sz.uh, ...
    'minimumwidth', largestuiwidth(h.(field))+20*sz.pixf);

[cshtags, cshtool] = getcshtags(this);
if isfield(cshtags, field)
    cshelpcontextmenu(h.(field), cshtags.(field), cshtool);
end

% [EOF]
