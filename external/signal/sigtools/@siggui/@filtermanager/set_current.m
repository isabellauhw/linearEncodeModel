function current = set_current(this, current)
%SET_CURRENT   PreSet function for the 'current' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

% Set the private property
set(this, 'privCurrentFilter', current);

% Send the event letting other objects know that a newfilter was selected.
send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% [EOF]
