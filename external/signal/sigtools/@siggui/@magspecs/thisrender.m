function thisrender(this, varargin)
%RENDER Render the magnitude specifications GUI component.
% Render the frame and uicontrols

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'mag'; end

hFig = get(this, 'FigureHandle');

% Call the super classes render method
super_render(this, pos);

h = get(this, 'Handles');

pos = get(h.framewlabel(1), 'Position');

lbl = getString(message('signal:sigtools:siggui:Units'));

% Put up popup label
sz = gui_sizes(this);

%Set the width depending on extent of the text
strs = {lbl};
w = largestuiwidth(strs)+ 5*sz.pixf;


units_lbl_pos = [pos(1)+sz.hfus pos(2)+pos(4)-sz.uh-2*sz.vfus-sz.lblTweak ...
    w sz.uh];

h.units_lbl = uicontrol(hFig,'Style','text',...
    'Units','pixels',...
    'Position',units_lbl_pos,...
    'Visible','off',...
    'String',lbl,...
    'Tag','units_lbl',...
    'HorizontalAlignment','left');

% Store the units of the object for setting up the popup
Type = get(this,'IRType');

popup_pos = [units_lbl_pos(1)+units_lbl_pos(3),...
        units_lbl_pos(2)+sz.lblTweak, ...
        sz.ebw+3*sz.uuhs sz.uh];

% Untranslated strings
strs = set(this, Type); 
% Translated strings
strsT = getTranslatedStringcell('signal:siggui:labelsandvalues:updateuis',strs); 
     
h.units = uicontrol(hFig,...
    'Style',           'popup',...
    'BackgroundColor', 'white',...
    'Units',           'pixels',...
    'Position',        popup_pos,...
    'String',          strsT,...
    'Tag',             'IRunits_popup',...
    'Visible',         'off',...
    'Value',           find(strcmpi(set(this,Type),this.(Type))), ...
    'Callback',        {@units_cb, this});

% Save untranslated strings in the app data for use in the callback  
setappdata(h.units, 'PopupStrings', strs);
  
% Store the handles in the object
set(this,'Handles',h);

renderlabelsnvalues(this, pos);

% Extract listener
wrl = this.WhenRenderedListeners;

% Install the listener for the units
% Install a listener for the response type
wrl = [ ...
        wrl ...
        handle.listener(this, [this.findprop('FIRUnits') this.findprop('IIRUnits')], ...
        'PropertyPostSet', @units_listener) ...
        handle.listener(this, this.findprop('IRType'), ...
        'PropertyPostSet', @irtype_listener) ...
    ];

set(wrl,'CallbackTarget',this);

% Store the listeners in the WhenRenderedListeners property of the superclass
this.WhenRenderedListeners = wrl;

%  Add contextsensitive help
cshelpcontextmenu(this, 'fdatool_ALL_mag_specs_frame');

% -------------------------------------------------------------------------
function units_cb(hcbo, eventData, this) %#ok<*INUSL>
%UNITS_POPUP_CB is the callback for the Units Popupmenu

% Get value from popup
indx = get(hcbo,'Value');

% Get the relevant type data
Type = get(this,'IRType');

% Set new units on the freqSpecs object
appData = getappdata(hcbo);
if ~isempty(appData) && isfield(appData,'PopupStrings')
  magUnitsOpts = appData.PopupStrings;
else
  magUnitsOpts = get(hcbo,'String');
end

set(this,Type,magUnitsOpts{indx});

% Send event to let listeners know what property has changed.
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% -------------------------------------------------------------------------
function units_listener(this, eventData) %#ok<*INUSD>

% Determine which impulse response type is current
Type = get(this,'IRType');

% Set the units popup to the index indicated by the current object's
% units property
set(this.Handles.units, 'Value', find(strcmp(get(this, Type), set(this,Type))));

% Update the uicontrols to reflect new state
update_labels(this);

% -------------------------------------------------------------------------
function irtype_listener(this, eventData)

% Determine the new irtype
currType = get(this, 'IRType');

% Untranslated strings
strs = set(this, currType); 
% Translated strings
strsT = getTranslatedStringcell('signal:siggui:labelsandvalues:updateuis',strs); 

% set the string to the list of all valid units for this type
set(this.Handles.units, 'String', strsT, ...
    'Value', find(strcmpi(set(this, currType), get(this, currType))));

% Save untranslated strings in the app data for use in the callback  
setappdata(this.Handles.units, 'PopupStrings', strs);
  
% Update all the uicontrols
update_labels(this);

% [EOF]
