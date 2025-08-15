function varargout = contextmenu(hPrm, h)
%CONTEXTMENU Create a context menu for the parameter
%   CONTEXTMENU(hPRM, H) create a context menu for the parameter hPRM on
%   the HG object H.  This function only works for parameter objects whose
%   'ValidValues' is a string vector (a cell of strings).
%
%   This function also maintains the check state of the UIMenus beneath the
%   contextmenu.  If a context menu already exists for the HG object, the 
%   UIMenus will be added to it with a separator.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

validate_inputs(hPrm, h);

[hc, sep] = addcsmenu(h);
labels    = get(hPrm, 'ValidValues');

% Loop over the labels and create menu items
for i = 1:length(labels)
    hm(i) = uimenu('Parent', hc, ...
        'Label', getTranslatedString('signal:sigtools:sigdatatypes',labels{i}), ...
        'Tag', labels{i}, ...
        'Callback', {@selection_cb, hPrm});
    
    % If the current label matches the value check it.
    if strcmpi(labels{i}, get(hPrm, 'Value'))
        set(hm(i), 'Checked', 'On');
    end
end

set(hm(1), 'Separator', sep);

% Add a listener to the NewValue event cb which will maintain the check state
l = [ ...
        handle.listener(hPrm, 'NewValue', @newvalue_eventcb); ...
        handle.listener(hPrm, hPrm.findprop('DisabledOptions'), ...
        'PropertyPostSet', @lcldisabledoptions_listener); ...
        handle.listener(hPrm, 'NewValidValues', @newvalidvalues_eventcb); ...
    ];
set(l, 'CallbackTarget', hm);
setappdata(hm(1), 'NewValueEventListener', l);

set(h, 'UIContextMenu', hc);

if nargout
    varargout = {hc, hm};
end

% -------------------------------------------------------------------
function newvalidvalues_eventcb(hm, eventData)

vv = get(eventData.Source, 'ValidValues');

for indx = 1:length(hm)
    set(hm(indx), 'Label', getTranslatedString('signal:sigtools:sigdatatypes',vv{indx}), 'Tag', vv{indx});
end

% -------------------------------------------------------------------
function lcldisabledoptions_listener(hm, eventData)

hObj = get(eventData, 'AffectedObject');

set(hm, 'Visible', 'Off');

vv = get(hObj, 'ValidValues');

for indx = 1:length(vv)
    set(findobj(hm, 'Tag', vv{indx}), 'Visible', 'On');
end

% -------------------------------------------------------------------
function newvalue_eventcb(hm, eventData)

set(hm, 'Checked', 'Off');
indx = find(strcmpi(get(eventData.Source, 'Value'), get(hm, 'Tag')));

set(hm(indx), 'Checked', 'On');

% -------------------------------------------------------------------
function selection_cb(hcbo, eventStruct, hPrm, hm)

setvalue(hPrm, get(hcbo, 'Tag'));

% -------------------------------------------------------------------
function validate_inputs(hPrm, h)
% Validate the inputs

if length(hPrm) ~= 1
    error(message('signal:sigdatatypes:parameter:contextmenu:MultipleParameterObjects'))
end

labels = get(hPrm, 'ValidValues');

if ~iscellstr(labels)
    error(message('signal:sigdatatypes:parameter:contextmenu:ParameterObjectsValidValues', 'Valid Values'))  
end

if ~ishghandle(h)
    error(message('signal:sigdatatypes:parameter:contextmenu:InputMustBeHandle'))  
end

% [EOF]
