function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to the enable property.

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.

dvalues = get(this, 'DisabledValues');

h = get(this, 'Handles');

loff = h.labels(dvalues);
setenableprop(loff, 'Off');
voff = h.values(dvalues);
setenableprop(voff, 'Off');

setenableprop(setdiff(h.labels, loff), this.Enable, false);
setenableprop(setdiff(h.values, voff), this.Enable, false);

% [EOF]
