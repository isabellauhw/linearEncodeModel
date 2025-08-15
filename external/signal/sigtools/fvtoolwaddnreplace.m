function hfvt = fvtoolwaddnreplace(Hd)
%FVTOOLWADDNREPLACE   Utility to enable FVTool with an Add/Replace property.
%   FVTOOLWADDNREPLACE(Hd) Adds a property to FVTool for enabling the
%   'Add Filter' and 'Replace Filter' features and return an FVTool object
%   handle.  These properties are to be used with FVTool's API methods:
%   addfilter and setfilter.
%   
%   See also LNKFVTOOL2MASK

%   Author(s): J. Schickler, P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,1);

hfvt = fvtool(Hd);

if isempty(findtype('signalAddReplace'))
    schema.EnumType('signalAddReplace', {'Add', 'Replace'});
end
p = hfvt.addprop('LinkMode');
p.SetObservable = true;
set(hfvt, 'LinkMode', 'Replace');

load fatoolicons;

% Find the toolbar of FVTool and add two buttons.
htoolbar = findobj(hfvt, 'type', 'uitoolbar');
htoolbar = htoolbar(end);
link.h.button = uitoggletool('Parent', htoolbar, ...
    'ClickedCallback', {@fullview_mode_cb, hfvt}, ...
    'Separator', 'on', ...
    'State', 'On', 'TooltipString', getString(message('signal:sigtools:fvtoolwaddnreplace:SetLinkModeToAdd')), ...
    'CData', icons.replace, 'Tag', 'mode');

% Create the menu to toggle the update_mode
link.h.menu = addmenu(hfvt, [1 4], 'Link','','link','on');
link.h.menu(2) = addmenu(hfvt, [1 4 1], getString(message('signal:sigtools:fvtoolwaddnreplace:ReplaceCurrentFilter')), ...
    {@fullview_mode_cb, hfvt}, 'replace', 'off', 'j');
link.h.menu(3) = addmenu(hfvt, [1 4 2], getString(message('signal:sigtools:fvtoolwaddnreplace:AddNewFilter')), ...
    {@fullview_mode_cb, hfvt}, 'add','off','k');

set(link.h.menu(2), 'Checked', 'On');

link.listener = addlistener(hfvt, p, 'PostSet', @(s,e)linkmode_listener(hfvt,e));
setappdata(hfvt, 'fullviewlink', link);

linkmode_listener(hfvt);

% ----------------------------------------------------------------------
function fullview_mode_cb(hcbo, eventStruct, hfvt)
% Callback to the menu items

if ishghandle(hcbo, 'uimenu')
    
    % Update the mode of the link with the tag of the menu item
    set(hfvt, 'LinkMode', get(hcbo, 'Tag'));
else
    if strcmpi(get(hcbo, 'State'), 'On')
        set(hfvt, 'LinkMode', 'Add');
    else
        set(hfvt, 'LinkMode', 'Replace');
    end
end

% ----------------------------------------------------------------------
function linkmode_listener(hfvt, eventData)

load fatoolicons;

if strcmpi(hfvt.LinkMode, 'Replace')
    str   = getString(message('signal:sigtools:fvtoolwaddnreplace:SetLinkModeToAdd'));
    icon  = icons.replace;
    state = 'off';
    hfvt.setfilter(hfvt.Filters{end});
else
    str   = getString(message('signal:sigtools:fvtoolwaddnreplace:SetLinkModeToReplace'));
    icon  = icons.add;
    state = 'on';
end

% Update the check marks of the Menu
link = getappdata(hfvt, 'fullviewlink');
set(link.h.menu, 'Checked', 'Off');
set(findobj(link.h.menu,'tag',lower(hfvt.LinkMode)), 'Checked', 'On');
set(link.h.button,'State', state, 'CData', icon, 'TooltipString', str);

set(hfvt, 'Children', get(hfvt, 'Children'));

% [EOF]
