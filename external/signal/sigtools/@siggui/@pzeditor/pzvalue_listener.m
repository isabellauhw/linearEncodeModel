function pzvalue_listener(this, eventData)
%PZVALUE_LISTENER Listener to the value of the Poles and Zeros

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Build the filter out of the new values.
if strcmpi(this.AnnounceNewSpecs, 'On')
    send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));
end
% send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

if isrendered(this)
    updatenumbers(this);
    if strcmpi(get(this, 'ButtonState'), 'Up')
        updatelimits(this);
    end
end

% [EOF]
