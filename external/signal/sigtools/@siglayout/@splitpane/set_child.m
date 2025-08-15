function child = set_child(this, child, field)
%SET_CHILD   PreSet function for the 'child' property.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.

if all(length(child) ~= [0 1])
    error(message('signal:siglayout:splitpane:set_child:InvalidDimensions'));
end

if ~ishghandle(child)
    error(message('signal:siglayout:splitpane:set_child:InvalidParam'));
end

if ~isempty(child)
    
    % Add a listener to the 'ObjectBeingDestroyed' event so that the handle
    % is removed from the object.
    this.ChildrenListeners.(field) = uiservices.addlistener(child, ...
        'ObjectBeingDestroyed', @(h, ev) remove(this, field));
    
    % Make sure that we keep the divider "on top" so that its buttondownfcn
    % will get called regardless of the contained objects positions.
    uistack(this.DividerHandle, 'top');

end

% [EOF]
