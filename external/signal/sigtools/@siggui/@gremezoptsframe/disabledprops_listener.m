function disabledprops_listener(this, eventData)
%DISABLEDPROPS_LISTENER Listener to the disabled props property

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(this, 'Handles');

if isempty(getbuttonprops(this))
    set(h.editadditionalparameters, 'Enable', 'Off');
else
    set(h.editadditionalparameters, 'Enable', this.Enable);
end

dprops = get(this, 'DisabledProps');

hoff = [];
for indx = 1:length(dprops)
    p = lower(dprops{indx});
    if isfield(h, p)
        hoff = union(hoff, [h.(p) h.([p '_lbl'])]);
    end
end

hall = handles2vector(this);

set(setdiff(hall, hoff), 'Visible', this.Visible);
set(hoff, 'Visible', 'Off');

% [EOF]
