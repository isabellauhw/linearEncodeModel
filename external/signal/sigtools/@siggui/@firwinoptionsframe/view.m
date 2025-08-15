function view(this)
%VIEW Launch WVTool

%   Author(s): V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

% sync the gui values
hwin = get(this, 'privWindow');

if isa(hwin, 'sigwin.functiondefined')
    set(hwin, 'MATLABExpression', this.FunctionName, ...
        'Parameters', evaluatevars(this.Parameter));
else
    p = getparamnames(hwin);
    if ~isempty(p)
        if ~iscell(p)
            set(hwin, p, evaluatevars(this.Parameter));
        else
            set(hwin, p{1}, evaluatevars(this.Parameter));
            set(hwin, p{2}, evaluatevars(this.Parameter2));
        end
    end
end

% Test is there's a valid window object
try
    data = generate(hwin);
catch
    error(message('signal:siggui:firwinoptionsframe:view:InvalidParam'));
end

send(this, 'OrderRequested', handle.EventData(this, 'OrderRequested'));

hV = getcomponent(this, '-class', 'sigtools.wvtool');
if isempty(hV)
    % Instantiate the Viewer
    hV = sigtools.wvtool;
    render(hV);
    
    % Install a listener to the WVToolClosing event
    listener = addlistener(hV, 'WVToolClosing', @(s,e)updatebtnstring(this,e));
    setappdata(this.Handles.view, 'Listener', listener);
    
    % Create a mean to setup the link mode (Add/Replace)
    createlinkmode(hV);

end

% Add or Replace window in the viewer
hFig = get(hV, 'FigureHandle');
AddReplaceMode = getappdata(hFig, 'AddReplaceMode');
addwin(hV, {hwin}, [], AddReplaceMode);

% Turn visibility on
set(hV, 'Visible', 'on');

hndls = get(this, 'Handles');
set(hndls.view, 'String', getString(message('signal:sigtools:siggui:Update')));

%-------------------------------------------------------------------------
function createlinkmode(hV)

hFig = get(hV, 'FigureHandle');

% Add a menu
hndl = addmenu(hFig,[1 3],'FDAToolLink','','fdatoollink','On','');
strs  = {getString(message('signal:sigtools:siggui:ReplaceCurrentWindow')),getString(message('signal:sigtools:siggui:AddNewWindow'))};
cbs   = {{@replace_cb, hV},{@add_cb, hV}};
tags  = {'replace','add'};
sep   = {'Off','Off'};
accel = {'J','K'};
hndl  = addmenu(hFig,[1 3 1],strs,cbs,tags,sep,accel);

% Default: Replace
set(hndl(1), 'Checked', 'on');

% Save the handles
setappdata(hndl(1), 'ExclusiveMenu', hndl(2));
setappdata(hndl(2), 'ExclusiveMenu', hndl(1));
setappdata(hFig, 'ReplaceMenuHandle', hndl(1));
setappdata(hFig, 'AddMenuHandle', hndl(2));

% Find the toolbar of the Viewer and add a button.
load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));
hFig = get(hV, 'FigureHandle');
htoolbar = findobj(hFig, 'type', 'uitoolbar');
link = [];
link.hbutton = uitoggletool('Parent', htoolbar, ...
    'ClickedCallback', {@addreplace_cb, hV}, ...
    'State', 'On', 'TooltipString', getString(message('signal:sigtools:siggui:SetLinkmodeadd')), ...
    'Separator','On', 'CData', icons.add, ...
    'Tag' , 'AddReplace');
setappdata(hFig, 'AddReplaceToggleHandle', link.hbutton);

setappdata(hFig, 'AddReplaceMode', 'Replace');

%-------------------------------------------------------------------------
function addreplace_cb(hcbo, eventStruct, hV)
% Callback of the toggle button

load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));

hFig = get(hV, 'FigureHandle');
state = get(hcbo, 'State');

if strcmpi(state, 'on')
    setlinktoreplace(hFig);
else
    setlinktoadd(hFig);
end


%-------------------------------------------------------------------------
function replace_cb(hcbo, eventStruct, hV)
% Callback of the Replace menu

hFig = get(hV, 'FigureHandle');
state = get(hcbo, 'Checked');

if strcmpi(state, 'off')
    setlinktoreplace(hFig);
end


%-------------------------------------------------------------------------
function add_cb(hcbo, eventStruct, hV)
% Callback of the Add menu

hFig = get(hV, 'FigureHandle');
state = get(hcbo, 'Checked');

if strcmpi(state, 'off')
    setlinktoadd(hFig);
end


%-------------------------------------------------------------------------
function setlinktoreplace(hFig)

load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));

% Update toggle
set(getappdata(hFig, 'AddReplaceToggleHandle'), 'TooltipString', getString(message('signal:sigtools:siggui:SetLinkmodeadd')), ...
    'CData', icons.replace, 'State', 'on');

% Update menus
set(getappdata(hFig, 'ReplaceMenuHandle'), 'Checked', 'on');
set(getappdata(hFig, 'AddMenuHandle'), 'Checked', 'off');

% Update Applicationdata
setappdata(hFig, 'AddReplaceMode', 'Replace');


%-------------------------------------------------------------------------
function setlinktoadd(hFig)

load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));

% Update toggle
set(getappdata(hFig, 'AddReplaceToggleHandle'), 'TooltipString', getString(message('signal:sigtools:siggui:SetLinkmodereplace')), ...
    'CData', icons.add, 'State', 'off');

% Update menus
set(getappdata(hFig, 'ReplaceMenuHandle'), 'Checked', 'off');
set(getappdata(hFig, 'AddMenuHandle'), 'Checked', 'on');

% Update Applicationdata
setappdata(hFig, 'AddReplaceMode', 'Add');


%-------------------------------------------------------------------------
function updatebtnstring(this, eventStruct)

set(this.Handles.view, 'String', getString(message('signal:sigtools:siggui:View')));

% [EOF]
