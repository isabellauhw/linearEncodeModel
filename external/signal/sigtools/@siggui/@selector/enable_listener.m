function enable_listener(hSct, eventData)
%ENABLE_LISTENER Listener to the enable property of the Selector

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

update(hSct, 'update_enablestates');

% [EOF]
