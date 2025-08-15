function disableoption(hObj, option)
%DISABLEOPTION Disable an option from among an enumerated type

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

vv = lower(get(hObj, 'AllOptions'));

option = lower(option);

if ~iscellstr(vv) | isempty(strmatch(option, vv))
    error(message('signal:sigdatatypes:parameter:disableoption:NotSupported'));    
end

do = get(hObj, 'DisabledOptions');

% If the option is already disabled, do nothing
indx = strmatch(option, vv);
if length(indx) > 1
    error(message('signal:sigdatatypes:parameter:disableoption:GUIErr'));
end

set(hObj, 'DisabledOptions', [do, indx]);

% Check to see if we have disabled the current selection.
vv = lower(get(hObj, 'ValidValues'));
v  = lower(get(hObj, 'Value'));

if isempty(strmatch(v,vv))
    setvalue(hObj, vv{1});
end

% [EOF]
