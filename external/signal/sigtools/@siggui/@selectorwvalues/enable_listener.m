function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to the enable property of the Selector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

update(this, 'update_enablestates');

set(allchild(this), 'Enable', this.Enable);

% [EOF]
