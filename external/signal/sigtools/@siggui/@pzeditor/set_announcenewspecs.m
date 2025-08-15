function value = set_announcenewspecs(this, value)
%SET_ANNOUNCENEWSPECS PostSet function for the 'announcenewspecs' property

%   Copyright 2011 The MathWorks, Inc.

send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% [EOF]
