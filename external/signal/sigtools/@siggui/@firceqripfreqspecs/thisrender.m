function thisrender(this, varargin)
%RENDER  Render the freqmagspecs frame and all associated uicontrols
%   RENDER(H, HFIG, POS)
%   H   -   Handle to freqmagspecs object
%   HFIG-   Handle to figure into which to render
%   POS -   Position at which the frame should be rendered

%   Author(s): Z. Mecklai
%   Copyright 1988-2011 The MathWorks, Inc.

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'freq' ; end

% Call the super classes render method
super_render(this, pos);

sz   = gui_sizes(this);
pos  = getpixelpos(this, 'framewlabel', 1);
hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

% Add a listener to the fsspecifier units property
fsh = getcomponent(this, 'siggui.specsfsspecifier');

% Render the FSSpecifier
render(fsh, hFig, pos);

% Get the name of the frequency prperty
Name = getdynamicname(this);

% Render the radio buttons
h.rbs_handles = render_popup(this, sz, fsh);
h.freq_handles = render_passstop_freq(this, sz, fsh, Name);
% handles.fs = get(fsh, 'handles');

% Complete the rest of the data management and listener installations
completerender(this, h, Name);

%  Add contextsensitive help
cshelpcontextmenu(this, 'fdatool_ALL_freq_specs_frame');


%-------------------------------------------------------------------------------
function completerender(this, handles, Name)

% Store the handle structure
set(this, 'Handles', handles);

% install listeners

% Extract listener
listeners = this.WhenRenderedListeners;

listeners(end+1) = handle.listener(this, ...
    this.findprop('FreqSpecType'), ...
    'PropertyPostSet', @FreqOpts_listener);

listeners(end+1) = handle.listener(this, ...
    this.findprop(Name), ...
    'PropertyPostSet', @Frequency_listener);

set(listeners, 'CallbackTarget',this);


% Install listeners
set(this, 'WhenRenderedListeners', listeners)

% Resize the FS label
fs_handles = handles.freq_handles(1);
position = get(fs_handles, 'Position');
strings = {'Fc:','Fpass:','Fstop:'};
position(3) = largestuiwidth(strings);
set(fs_handles,'Units','pixels');
set(fs_handles, 'Position', position);
set(fs_handles,'Units','normalized');

set(fs_handles, 'String', [Name,':']);

%-------------------------------------------------------------------------------
function popup_handles = render_popup(this, sz, fsh)
%RENDER_RADIO_BUTTONS  Render the radio buttons

labels = {getString(message('signal:sigtools:siggui:Cutoff')), ...
          getString(message('signal:sigtools:siggui:PassbandEdge')),...
          getString(message('signal:sigtools:siggui:StopbandEdge'))};

setunits(fsh, 'pixels');
handles = get(fsh, 'Handles');
lblPos = get(handles.value_lbl, 'Position');
lblPos(2) = lblPos(2) - 1*(sz.uh + sz.uuvs);
lblPos(3) = largestuiwidth({getString(message('signal:sigtools:siggui:Specify'))});
ebPos = get(handles.value, 'Position');
ebPos(2) = ebPos(2) - 1*(sz.uh + sz.uuvs);
setunits(fsh, 'normalized');

hFig = get(this, 'FigureHandle');

popup_handles(1) = uicontrol('Style','Text',...
    'Parent',hFig,...
    'Visible','off',...
    'Enable','on',...
    'String', getString(message('signal:sigtools:siggui:Specify')),...
    'HorizontalAlignment','left',...
    'Units','pixels',...
    'Position',lblPos);

popup_handles(2) = uicontrol('Style','popup',...
    'Parent',hFig,...
    'Visible','off',...
    'Enable','on',...
    'BackgroundColor','w',...
    'String', labels,...
    'Callback',{@popup_callback, this},...
    'Units','pixels',...
    'Position', ebPos);


CurrOpt = get(this, 'FreqSpecType');
AllOpts = set(this, 'FreqSpecType');

I = find(strcmp(AllOpts, CurrOpt));

set(popup_handles(2), 'Value', I);


%-------------------------------------------------------------------------------
function popup_callback(hSource, eventdata, this) %#ok<INUSL>
%RBS_CALLBACK  Callback for the radio buttons

% Get the index
I = get(hSource, 'Value');

% Turn the radio button selected on
set(hSource, 'Value', I);

% Set the option to the one selected from the radio button
AllOpts = set(this, 'FreqSpecType');

set(this, 'FreqSpecType', AllOpts{I});
% Send event
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

%-------------------------------------------------------------------------------
function freq_handles = render_passstop_freq(this, sz, fsh, Name)
%RENDER_PASSSTOP_FREQ  Render the label and edit box for the passband/stopband freq

setunits(fsh, 'Pixels');
handles = get(fsh, 'Handles');
lblPos = get(handles.value_lbl, 'Position');
lblPos(2) = lblPos(2) - 2*(sz.uh + sz.uuvs);
ebPos = get(handles.value, 'Position');
ebPos(2) = ebPos(2) - 2*(sz.uh + sz.uuvs);
setunits(fsh, 'Normalized');

hFig = get(this, 'FigureHandle');

freq_handles(1) = uicontrol('Style','text',...
    'Parent',hFig,...
    'Visible','off',...
    'Enable','on',...
    'Units','pixels',...
    'Position', lblPos,...
    'HorizontalAlignment', 'left');

freq_handles(2) = uicontrol('Style','edit',...
    'Parent',hFig,...
    'Visible','off',...
    'Enable','on',...
    'Units','pixels',...
    'Position',ebPos,...
    'HorizontalAlignment','left',...
    'String', get(this, Name),...
    'Callback', {@Frequency_callback, this},...
    'BackgroundColor','w');

setenableprop(freq_handles, 'on');

%-------------------------------------------------------------------------------
function Frequency_callback(hSource, eventData, this) %#ok<INUSL>
%FREQUENCY_CALLBACK  Callback for the passband/stopband frequency edit box

% Get the name of the frequency prperty
Name = getdynamicname(this);

% Fix up the edit box and get the string entered
strs = fixup_uiedit(hSource);

% Set the frequency property
set(this, Name, strs{1});

% Send event
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% [EOF]
