function enableoption(hObj, option)
%ENABLEOPTION Enable an option from among an enumerated type

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

vv = lower(get(hObj, 'AllOptions'));
option = lower(option);

if ~iscellstr(vv) | isempty(strmatch(option, vv))
    error(message('signal:sigdatatypes:parameter:enableoption:NotSupported'));    
end

do = get(hObj, 'DisabledOptions');

set(hObj, 'DisabledOptions', setdiff(do, strmatch(option, vv)));

% [EOF]
