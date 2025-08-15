function size = figuresize(hBase, units)
%FIGURESIZE Return the figure size.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,2);

if nargin == 1, units = 'pixels'; end

hFig = get(hBase, 'FigureHandle');

if ~ishghandle(hFig)
    error(message('signal:siggui:siggui:figuresize:InvalidParam'));
end

origUnits = get(hFig,'Units');
set(hFig,'Units',units);
pos = get(hFig,'Position');
set(hFig,'Units',origUnits);

size = pos(3:4);

% [EOF]
