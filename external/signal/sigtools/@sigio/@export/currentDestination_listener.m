function currentDestination_listener(this)
%CURRENTDESTINATION_LISTENER Listener to 'currentDestination'

%   Copyright 2008 The MathWorks, Inc.

% Set the popup string to match the current destination.
h = get(this, 'Handles');
idx = find(strcmp(this.CurrentDestination, this.AvailableDestinations));
if isempty(idx), idx = 1; end

set(h.xp2popup, 'Value', idx);

% [EOF]
