function sethost(hFDA,fcnhandle)
%SETHOST Adds a host to FDATool.
%   SETHOST(HFDA,FCNH) Adds a host to the FDATool session specified by the
%   session HFDA.  The function handle, FCNH, points to a function which
%   will return the proper FDATool structure with host information.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

narginchk(2,2);

hFig = get(hFDA,'FigureHandle');
ud = get(hFig,'UserData');

% Assign into ud.host the output of fdaregisterhost (an FDATool host structure)
ud.host = feval(fcnhandle);
set(hFig,'UserData',ud);

% [EOF]
