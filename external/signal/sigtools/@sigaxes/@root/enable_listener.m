function enable_listener(hObj, eventData) %#ok<INUSD>
%ENABLE_LISTENER Listener to the enable property

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(hObj, 'Handles');

if strcmpi(hObj.Enable, 'Off')
    
    props = getdisabledprops(hObj);
    
    % When the root is disabled, set its color to gray and disable its
    % buttondownfcn and uicontextmenu.
    set(h.line, 'ButtonDownFcn', [], 'UIContextMenu', [], props{:});
else
    
    % Reenable the callbacks and make sure the object looks right.
    if strcmpi(hObj.Current, 'Off')
        props = getdefaultprops(hObj);
    else
        props = getcurrentprops(hObj);
    end
    
    set(h.line, 'ButtonDownFcn', hObj.ButtonDownFcn, ...
        'UIContextMenu', hObj.UIContextMenu, props{:});
        
    set(h.line, 'PickableParts', 'All')
     
end

% [EOF]
