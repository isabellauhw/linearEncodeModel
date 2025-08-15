function setdatamarkers(hcbo,eventStruct,dataMarkerFcn)
%SETDATAMARKERS Set interactive data markers. 
%   SETDATAMARKERS is used as the 'ButtonDownFcn' of a line
%   in order to enable Data Markers.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

hFig = ancestor(hcbo, 'figure');

if isappdata(hFig, 'DataCursorManager')
    hDCM = getappdata(hFig, 'DataCursorManager');
else
    hDCM = datacursormode(hFig);
    setappdata(hFig, 'DataCursorManager', hDCM);
end

hB = hgbehaviorfactory('datacursor');

if nargin < 3
    hB.UpdateFcn = @stringFcn;
else
    hB.UpdateFcn = dataMarkerFcn;
end

hgaddbehavior(hcbo,hB);

h = hDCM.createDatatip(hcbo);

h.UIContextMenu = uicontextmenu('Parent',ancestor(hcbo,'figure'));
h.OrientationMode = 'Auto';

datacursormenus(h,'alignment','fontsize','movable','interpolation', 'export','delete','deleteall');

% -------------------------------------------------------------------------
function dataTip = stringFcn(hLine, eventData)
hAx  = ancestor(hLine, 'axes');

hxlbl = get(hAx,'XLabel'); xlbl = get(hxlbl,'String'); 
hylbl = get(hAx,'YLabel'); ylbl = get(hylbl,'String'); 

%trim the brackets part to get the shorter version label
xlbl = localTrimBrackets(xlbl);
ylbl = localTrimBrackets(ylbl);

dataTip = sprintf('%s: %.7g\n%s: %.7g', xlbl, eventData.Position(1), ...
    ylbl, eventData.Position(2));

function output = localTrimBrackets(input)
idx = findstr(input, '(');
if ~isempty(idx)
    output = strtrim(input(1:idx-1));
else
    output = strtrim(input);
end
% [EOF] 








