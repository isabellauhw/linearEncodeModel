function sos_listener(h, eventData)
%SOS_LISTENER Listener to the sos property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

prop_listener(h, 'sos');

update_labels(h, eventData);
update_editboxes(h, eventData);

% [EOF]
