function hAxes = copyAxes(hSource, copyFcn, hFigNew)
%COPYAXES Copy the axes and retain data markers.

%   Copyright 2008-2014 The MathWorks, Inc.

% Allow callers to specify lines/axes.
hFigOld = ancestor(hSource, 'figure');

if nargin < 3
  hFigNew = figure('NumberTitle', 'Off', 'Visible', 'Off');
end

% If we are not given a function, just copy all the axes.
if nargin < 2
  copyFcn = @(hSource, hFigNew) lclCopyAxes(hSource, hFigNew);
end

% Copy the axes using the passed function.
hAxes = copyFcn(hFigOld, hFigNew);

% -------------------------------------------------------------------------
function hAxes = lclCopyAxes(hSource, hFigNew)

if ishghandle(hSource, 'figure')
  hAxesOld = findobj(hSource, 'type', 'axes');
else
  hAxesOld = ancestor(hSource, 'axes');
end

hAxes = copyobj(hAxesOld, hFigNew);

% [EOF]
