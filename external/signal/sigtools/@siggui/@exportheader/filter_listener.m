function filter_listener(hEH, eventData)
%FILTER_LISTENER Listener to the filter of the exportheader object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

update_variables(hEH);
update_datatype(hEH);

if isrendered(hEH)
    resetoperations(hEH);
end

% [EOF]
