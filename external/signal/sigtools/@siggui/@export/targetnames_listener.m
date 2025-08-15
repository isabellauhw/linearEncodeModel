function targetnames_listener(hXP, eventData)
%TARGETNAMES_LISTENER Listener to the TargetNames property

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h  = get(hXP,'Handles');
if iscoeffs(hXP)
    targ = get(hXP,'TargetNames');
else
    targ = get(hXP, 'ObjectTargetNames');
end

% If the # of edit boxes does not match the number of targetnames, rerender.
if length(h.edit) ~= max([length(get(hXP,'TargetNames')), length(get(hXP,'ObjectTargetNames'))])
    render_editboxes(hXP);
end

update_popup(hXP);
update_editboxes(hXP);

set(hXP, 'IsApplied', 0);

% [EOF]
