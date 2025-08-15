function fullviewlink(hFDA)
%FULLVIEWLINK Creates a linked FVTool to FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hFig = get(hFDA, 'FigureHandle');
setptr(hFig, 'watch');

% Create a full view of FDATool's Analysis
hfig = createfullview(hFDA);

% Link the full view to FDATool
installfullviewlink(hfig, hFDA);

setptr(hFig, 'arrow');

%-------------------------------------------------------------------------
function hfig = createfullview(hFDA)
%Load a session of FVTool that matches FDATool

% Get Filter information
filtobj = copy(getfilter(hFDA, 'wfs'));

% Get current analysis
hFVT        = getfvtoolhandle(hFDA);

hfig = fvtool(filtobj,param2struct(get(hFVT, 'Parameters')),...
    'Analysis', hFVT.Analysis, ...
    'OverlayedAnalysis', hFVT.OverlayedAnalysis, ...
    'Grid', hFVT.Grid, 'Legend', hFVT.Legend, 'DesignMask', hFVT.DisplayMask);

%-------------------------------------------------------------------------
function installfullviewlink(hfig, hFDA)
%Link FDATool and FVTool

load fatoolicons;

% Find the toolbar of FVTool and add two buttons.
htoolbar = findobj(hfig, 'type', 'uitoolbar');
htoolbar = htoolbar(end);
link.h.button = uitoggletool('Parent', htoolbar, ...
    'ClickedCallback', {@fullview_link_cb, hFDA}, ...
    'State', 'On', 'TooltipString', getString(message('signal:sigtools:private:DeactivateFDAToolLink')), ...
    'Separator','On', 'CData', icons.link, 'Tag', 'fdatoollink');
link.h.button(2) = uitoggletool('Parent', htoolbar, ...
    'ClickedCallback', {@fullview_mode_cb, hfig}, ...
    'State', 'On', 'TooltipString', getString(message('signal:sigtools:private:SetLinkModeToAdd')), ...
    'CData', icons.replace, 'Tag', 'mode');

% Create the menu to toggle the update_mode
link.h.menu = addmenu(hfig, [1 4], 'FDAToolLink','','fdatoollink','on');
link.h.menu(2) = addmenu(hfig, [1 4 1], getString(message('signal:sigtools:private:ReplaceCurrentFilter')), ...
    {@fullview_mode_cb, hfig}, 'replacefilter', 'off', 'j');
link.h.menu(3) = addmenu(hfig, [1 4 2], getString(message('signal:sigtools:private:AddNewFilter')), ...
    {@fullview_mode_cb, hfig}, 'addfilter','off','k');
link.mode = 'replacefilter';

set(link.h.menu(2), 'Checked', 'On');

% Set up listeners to FDATool's filter and FDAToolClosing
link.h.listen = handle.listener(hFDA, 'FilterUpdated', {@filterlistener, hfig});
link.h.listen(2) = handle.listener(hFDA, 'sigguiClosing', {@fdatoolclose_eventcb, hfig});

setappdata(hfig, 'fullviewlink', link);


%-------------------------------------------------------------------------
function filterlistener(hFDA, eventData, hfig)
% Listener to the filter of fdatool

filtobj = getfilter(hFDA, 'wfs');
hFVT = siggetappdata(hfig, 'fvtool', 'handle');
link = getappdata(hfig, 'fullviewlink');

if strcmpi(link.mode, 'replacefilter')
    
    % Replace the last filter in FVTool with the new filter
    filtobjs = get(hFVT,'Filters');
    filtobjs(end) = filtobj;
    hFVT.setfilter(filtobjs);
elseif strcmpi(link.mode, 'addfilter')
    
    % Add FDATool's filter to FVTool
    hFVT.addfilter(filtobj);
else
    error(message('signal:fullviewlink:InternalError', mode));
end

%-------------------------------------------------------------------------
function fdatoolclose_eventcb(hFDA, eventStruct, hfig)
% Delete the full view link when FDATool is destroyed.

% Get and remove the appdata from FVTool
appStr = 'fullviewlink';
link   = getappdata(hfig, appStr);
rmappdata(hfig, appStr);

% Delete Full View Link button and menu items
delete([link.h.button link.h.menu]);

% Delete the listeners
delete(link.h.listen);

%-------------------------------------------------------------------------
%       Callbacks
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function fullview_mode_cb(hcbo, eventStruct, hfig)
% Callback to the menu items

load fatoolicons;

link = getappdata(hfig, 'fullviewlink');

if ishghandle(hcbo, 'uimenu')
    
    % Update the mode of the link with the tag of the menu item
    link.mode = get(hcbo, 'Tag');
else
    if strcmpi(get(hcbo, 'State'), 'On')
        link.mode = 'replacefilter';
    else
        link.mode = 'addfilter';
    end
end

if strcmpi(link.mode, 'replacefilter')
    str   = getString(message('signal:sigtools:private:SetLinkModeToAdd'));
    icon  = icons.replace;
    state = 'on';
else
    str   = getString(message('signal:sigtools:private:SetLinkModeToReplace'));
    icon  = icons.add;
    state = 'off';
end

setappdata(hfig, 'fullviewlink', link);

% Update the check marks of the Menu
set(link.h.menu, 'Checked', 'Off');
set(findobj(link.h.menu,'tag',link.mode), 'Checked', 'On');
set(findobj(link.h.button,'tag','mode'), ...
    'State', state, 'CData', icon, 'TooltipString', str);
lclfixtoolbars(hfig)

%-------------------------------------------------------------------------
function fullview_link_cb(hcbo, eventStruct, hFDA)
% Callback to the toggle button

load fatoolicons;

state = get(hcbo, 'State');
hfig  = get(get(hcbo, 'Parent'), 'Parent');

% Enable or disable the filterlistener depending on the state of the button
link = getappdata(hfig, 'fullviewlink');
set(link.h.listen(1), 'Enabled', state);

if strcmpi(state, 'on')
    
    % Resync the filters
    filterlistener(hFDA, eventStruct, hfig);
    set(hcbo, 'TooltipString', getString(message('signal:sigtools:private:DeactivateFDAToolLink')), ...
        'CData', icons.link);
else
    set(hcbo, 'TooltipString', getString(message('signal:sigtools:private:ActivateFDAToolLink')), ...
        'CData', icons.unlink);
end
lclfixtoolbars(hfig)

% Enable or disable the mode menu item depending on the state of the button
set(link.h.menu,'Enable',state);
set(findobj(link.h.button, 'tag', 'mode'), 'Enable', state);

%-------------------------------------------------------------------
function lclfixtoolbars(hfig)

% This was meant to fix g142297, but it causes a SEGV g142769
% set(hfig, 'Children', get(hfig, 'Children'));

% [EOF]
