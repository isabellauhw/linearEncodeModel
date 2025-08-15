function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to the enable property of the design panel

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

sigcontainer_enable_listener(this, eventData);

if isempty(this.CurrentDesignMethod)
    set(this.Frames(3:4), 'Enable', this.Enable);
end

% [EOF]
