function varargout = cshelpcontextmenu(hFig, hItem, tagStr, toolname)
%CSHELPCONTEXTMENU   Add a "What's This?" context menu.
%   HC = CSHELPCONTEXTMENU(HITEM,TAGSTR,TOOLNAME) adds a context menu to
%   the uicontrol HITEM.  TAGSTR is assigned as the tag to the UIMENU.
%   TOOLNAME defines which TOOLNAME_help.m file could be used in
%   determining the documentation mapping. The handle to  the contextmenu
%   is returned.
%
%   See also CSHELPENGINE, CSHELPGENERAL_CB, RENDER_CSHELPBTN

%   Author(s): D.Orofino, V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

if ischar(hItem)
    narginchk(3,3);
    toolname = tagStr;
    tagStr   = hItem;
    hItem    = hFig;
    hFig     = ancestor(hItem(1), 'figure');
else
    narginchk(4,4);
end

tag = ['WT?' tagStr];

hm = [];
hc = [];
if length(hItem) == 1
    hc = get(hItem, 'UIContextMenu');
    if ~isempty(hc)
        hm = findobj(hc, '-regexp', 'Tag', 'WT?');
    end
end

if isempty(hc)
    hc = uicontextmenu('Parent', hFig);
end
if isempty(hm)
    hm = uimenu('Label', getString(message('signal:sigtools:sigtools:WhatsThis')),...
        'Parent', hc);
    set(hItem,'UIContextMenu',hc);
end
set(hm, 'Callback', {@cshelpengine,toolname,tag}, ...
    'Tag', tag);

if nargout >= 1
    varargout{1} = hc;
end

% [EOF]
