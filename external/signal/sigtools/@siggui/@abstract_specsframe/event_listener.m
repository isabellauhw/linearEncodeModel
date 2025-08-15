function event_listener(h, eventData)
%EVENT_LISTENER listens to the event sent by the fsspecifier

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.

% freqspecs_event_cb(h, eventData);
send(h, 'UserModifiedSpecs', handle.EventData(h, 'UserModifiedSpecs'));

% [EOF]
