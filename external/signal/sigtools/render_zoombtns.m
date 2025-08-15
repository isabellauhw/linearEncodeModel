function varargout = render_zoombtns(hFig)
%RENDER_ZOOMBTNS Render the Zoom In and Zoom Out toggle buttons.
%
%   Input:
%     hut - Handle to the Toolbar
%     cbstruct - Structure of function handles for the CallBacks.
%
%   Output:
%     htoolbar - Vector containing handles to the zoom buttons.

%   Author(s): P. Costa 
%   Copyright 1988-2017 The MathWorks, Inc.

hut  = findall(hFig,'type','uitoolbar');

if isempty(hut)
    hut = uitoolbar(hFig);
end

% Load the MAT-file with the icons 
icons = load('zoom_icons.mat');

% Install factory toolbars.
hbtns(1) = uitoolfactory(hut, 'Exploration.ZoomIn');
hbtns(2) = uitoolfactory(hut, 'Exploration.ZoomX');
hbtns(3) = uitoolfactory(hut, 'Exploration.ZoomY');
hbtns(4) = uipushtool('Parent', hut, ...
    'CData',           icons.fullviewCData, ...
    'ClickedCallback', @(h, ev) defaultView(hFig), ...
    'Tag',             'defaultview', ...
    'TooltipString',   getString(message('signal:sigtools:render_zoommenus:RestoreDefaultView')));

% Use the new zoom icons instead of ones in uitoolfactory
set(hbtns(1), ...
    'CData', icons.zoomplusCData, ...
    'Separator', 'on');
set(hbtns(2), ...
    'CData', icons.zoomxCData);
set(hbtns(3), ...
    'CData', icons.zoomyCData);

if nargout>0
    varargout{1} = hbtns;
end

%% ------------------------------------------------------------------------
function defaultView(hFig)

hAxes = findall(hFig, 'type', 'axes');

for indx = 1:length(hAxes)
    if ~strcmpi(getappdata(hAxes(indx), 'zoomable'), 'off') && ...
            ~strcmpi(get(hAxes(indx), 'Tag'), 'legend') && ...
            ~strcmpi(get(hAxes(indx), 'Tag'), 'scribeOverlay')
        zoom(hAxes(indx), 'out');
    end
end

% [EOF]
