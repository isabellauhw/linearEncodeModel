function out = setlibrary(hObj, out)
%SETLIBRARY Check if the library is valid

%   Copyright 1995-2017 The MathWorks, Inc.

hPrm = get(hObj, 'Parameter');
libs = libraries(hPrm);
indx = strmatch(out, libs);

switch length(indx)
case 0
    error(message('signal:siggui:dspfwiz:setlibrary:NotSupported'));
case 1
    out = libs{indx};
otherwise % More than 1 match
    error(message('signal:siggui:dspfwiz:setlibrary:GUIErr'));
end

% EOF
