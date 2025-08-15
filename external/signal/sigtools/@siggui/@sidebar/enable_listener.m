function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to the Enable Property

%   Author(s): J. Schickler
%   Copyright 1988-2015 The MathWorks, Inc.

sigcontainer_enable_listener(this, eventData);

h     = get(this, 'Handles');
index = get(this, 'CurrentPanel');

% Do not try to update buttons if they do not exist
if ~isempty(h.button) && ~isequal(index, 0) && strcmpi(this.Enable, 'On')
    set(h.button(index), 'Enable', 'Inactive');
end

% [EOF]
