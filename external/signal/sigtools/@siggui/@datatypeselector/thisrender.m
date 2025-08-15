function thisrender(this, hFig, pos)
%THISRENDER Render the DataTypeSelector
%   THISRENDER(this, hFIG, POS) Render the data type selector to hFIG in the
%   position POS.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

sz   = gui_sizes(this);
if nargin < 3
    pos = [10 10 458 112]*sz.pixf;
    if nargin < 2
        hFig = gcf;
    end
end

hPanel = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', pos, ...
    'Title', getString(message('signal:sigtools:siggui:Datatypetouseexport')), ...
    'Visible', 'Off');

hLayout = siglayout.gridbaglayout(hPanel, ...
    'HorizontalGap', 5, ...
    'HorizontalWeights', [1 1]);

sz = gui_sizes(this);

h.selection = uicontrol(hPanel, ...
    'Callback', {@selection_cb, this}, ...
    'Tag', 'suggested', ...
    'String', getString(message('signal:sigtools:siggui:ExportSuggested')), ...
    'Style', 'radio');

h.selection(2) = uicontrol(hPanel, ...
    'Callback', {@selection_cb, this}, ...
    'String', getString(message('signal:sigtools:siggui:ExportAs')), ...
    'Tag', 'exportas', ...
    'Style', 'radio');

width = largestuiwidth(h.selection)+25*sz.pixf;

hLayout.add(h.selection(1), [1 2], 1, ...
    'TopInset', 15*sz.pixf, ...
    'MinimumHeight', sz.uh, ...
    'MinimumWidth', width, ...
    'Anchor', 'East');

hLayout.add(h.selection(2), [3 4], 1, ...
    'MinimumHeight', sz.uh, ...
    'MinimumWidth', width, ...
    'BottomInset', 5*sz.pixf, ...
    'Anchor', 'East');

h.suggested = uicontrol(hPanel,...
    'HorizontalAlignment', 'Left', ...
    'Style', 'text');

h.exportas = uicontrol(hPanel, ...
    'String', gettypes, ...
    'Style', 'popup', ...
    'Tag',   'datatype_popup', ...
    'Callback', {@exportas_cb, this});

h.fractional = uicontrol(hPanel, ...
    'Style', 'text', ...
    'Tag', 'datatype_fractional_length', ...
    'HorizontalAlignment', 'Left', ...
    'String', [getString(message('signal:sigtools:siggui:FractionalLength')) ': ']);

hLayout.add(h.suggested, [1 2], 2, ...
    'MinimumHeight', 2*sz.uh, ...
    'TopInset', 20*sz.pixf, ...
    'Anchor', 'west', ...
    'Fill', 'Horizontal')

hLayout.add(h.exportas, 3, 2, ...
    'MinimumHeight', sz.uh, ...
    'MinimumWidth', largestuiwidth(h.exportas)+40*sz.pixf, ...
    'Anchor', 'west', ...
    'TopInset', 5*sz.pixf);

hLayout.add(h.fractional, 4, 2, ...
    'Anchor', 'NorthWest', ...
    'TopInset', 2*sz.pixf, ...
    'Fill', 'Horizontal');

set(this, 'Handles', h, 'Layout', hLayout, 'Container', hPanel, 'Parent', hFig);

enable_listener(this, []);
selection_listener(this);
suggestedtype_listener(this);
exporttype_listener(this);
fractionallength_listener(this);

% Create listeners to update the HG objects
listen = [handle.listener(this, this.findprop('Selection'), ...
    'PropertyPostSet', @selection_listener); ...
    handle.listener(this, this.findprop('SuggestedType'), ...
    'PropertyPostSet', @suggestedtype_listener); ...
    handle.listener(this, this.findprop('ExportType'), ...
    'PropertyPostSet', @exporttype_listener); ...
    handle.listener(this, this.findprop('FractionalLength'), ...
    'PropertyPostSet', @fractionallength_listener); ...
    ];

% Set the callback target to itself and disable the listeners.
set(listen, 'CallbackTarget', this);

% These are when rendered listeners because they update the HG objects
set(this, 'WhenRenderedListeners', listen);

setupenablelink(this, 'Selection', 'exportas', 'exportas');

% -------------------------------------------------------------------------
function exportas_cb(hcbo, eventStruct, this)

str = popupstr(hcbo);

indx = find(strcmpi(str, gettypes));

alltypes = set(this, 'ExportType');

set(this, 'ExportType', alltypes{indx});

% -------------------------------------------------------------------------
function selection_cb(hcbo, eventStruct, this)

selection = get(hcbo, 'Tag');
set(this, 'Selection', selection);

% -------------------------------------------------------------------------
function selection_listener(this, eventData)

h    = get(this, 'Handles');
hon  = findobj(h.selection, 'Tag', this.Selection);
hoff = setdiff(h.selection, hon);

set(hon,  'Value', 1);
set(hoff, 'Value', 0);

% -------------------------------------------------------------------------
function suggestedtype_listener(this, eventData)

h    = get(this, 'Handles');
type = get(this, 'SuggestedType');

% Set up the default datatype string
switch type

case 'single'        
    dataTypeStr = sprintf(getString(message('signal:sigtools:siggui:Singleprecisionfloatingpoint')));
case 'double'        
    dataTypeStr = sprintf(getString(message('signal:sigtools:siggui:Doubleprecisionfloatingpoint')));
    
otherwise
    indx = strfind(type, 'int');
    bits = type(indx+3:end);
    if strcmpi(type(1), 'u')     
        dataTypeStr  = sprintf(getString(message('signal:sigtools:siggui:Unsignedbitintegerwithfractionallength',...
            bits,num2str(this.FractionalLength))));
    else
        dataTypeStr  = sprintf(getString(message('signal:sigtools:siggui:Signedbitintegerwithfractionallength',...
            bits,num2str(this.FractionalLength))));
    end
end

% Set string in uicontrols and store information in the uicontrol user data
set(h.suggested(1), 'String', dataTypeStr);

% -------------------------------------------------------------------------
function exporttype_listener(this, eventData)

alltypes = set(this, 'ExportType');

indx = find(strcmpi(this.ExportType, alltypes));
set(this, 'ExportType', alltypes{indx});

update_fraclength(this);

% -------------------------------------------------------------------------
function fractionallength_listener(this, eventData)

update_fraclength(this);
suggestedtype_listener(this);

% -------------------------------------------------------------------------
function update_fraclength(this)

h = get(this, 'Handles');

set(h.fractional, 'String', sprintf([getString(message('signal:sigtools:siggui:FractionalLength')) ': %d'], this.getfraclength('pop')));

% -------------------------------------------------------------------------
function types = gettypes

types = {getString(message('signal:sigtools:siggui:Signed32bitInteger')),getString(message('signal:sigtools:siggui:Signed16bitInteger')),getString(message('signal:sigtools:siggui:Signed8bitInteger')), ...
    getString(message('signal:sigtools:siggui:USigned32bitInteger')),getString(message('signal:sigtools:siggui:USigned16bitInteger')), getString(message('signal:sigtools:siggui:USigned8bitInteger')), ...
    getString(message('signal:sigtools:siggui:Doubleprecisionfloat')),getString(message('signal:sigtools:siggui:Singleprecisionfloat'))};

% [EOF]
