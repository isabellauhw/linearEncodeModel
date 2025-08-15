function setstate(hObj, s)
%SETSTATE set the state of the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if isfield(s, 'exportto')
    news.exporttarget = s.exportto;
    news.overwrite = s.overwritechk;
    s = news;
end

siggui_setstate(hObj, s);

% [EOF]
