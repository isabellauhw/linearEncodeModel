function sendnewspecs(hObj)
%SENDNEWSPECS Send the NewSpecs Event

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if strcmpi(hObj.AnnounceNewSpecs, 'on')
    send(hObj, 'NewSpecs', handle.EventData(hObj, 'NewSpecs'));
end

% [EOF]
