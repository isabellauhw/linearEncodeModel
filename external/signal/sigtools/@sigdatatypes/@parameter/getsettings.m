function value = getsettings(hPrm, eventData)
%GETSETTINGS Get the value from the eventdata

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if ~isempty(eventData) & strcmpi(get(eventData, 'Type'), 'UserModified')
    value = get(eventData, 'Data');
else
    value = get(hPrm, 'Value');
end

% [EOF]
