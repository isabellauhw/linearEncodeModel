function setfdasessionhandle(h,hFig)
%SETFDASESSIONHANDLE  Set the handle to an FDATool session.

%   Author(s): R. Losada
%   Copyright 1988-2010 The MathWorks, Inc.


ud = get(hFig,'UserData');

ud = setfield(ud,'sessionHandle',h);

set(hFig,'UserData',ud);

