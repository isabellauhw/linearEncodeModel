function varargout = fdaddcontextmenu(hFig,hItem,tagStr)
% FDADDCONTEXTMENU   Add a "What's This?" context menu.
%   FDADDCONTEXTMENU(HFIG,HITEM,TAGSTR) adds a context menu to the
%   uicontrol HITEM, whose parent is HFIG.  TAGSTR is assigned as
%   the tag to the UIMENU

%   Author(s): D. Orofino 
%   Copyright 1988-2002 The MathWorks, Inc.

varargout{1} = cshelpcontextmenu(hFig,hItem,tagStr, 'FDATool');

% [EOF]
