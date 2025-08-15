function this = fdatool
%SESSION  Constructor for an FDATool session object.
%
%   Inputs:
%      hFig - Handle to the figure corresponding to the session.
%
%   Outputs:
%      h - Handle to the instance of the class.

%   Author(s): R. Losada
%   Copyright 1988-2010 The MathWorks, Inc.

this = sigtools.fdatool;

% Set properties
set(this,'SessionType','default');
set(this,'FileName', 'untitled.fda');
set(this,'Version',1.1);
set(this,'LaunchedBySPTool', 0);

set(this,'filterMadeBy','');

addlistener(this, 'NewAnalysis', @newanalysis_eventcb, this);

% ---------------------------------------------------
function newanalysis_eventcb(this, eventData)
%NEWANALYSIS_EVENTCB Listener to the NewAnalysis Event

h           = gethandles(this);
analysisStr = get(eventData, 'Data');

hTitle = h.analysis.frame(2);
origUnits = get(hTitle, 'Units');
set(hTitle, 'String', analysisStr, 'Units', 'Pixels');
uiExtent = get (hTitle, 'Extent');
pos = get(hTitle, 'Position');
pos(3) = uiExtent(3);
set(hTitle,'Position', pos, 'String', analysisStr, 'Units', origUnits);

% We want to ignore all zooming warnings
w = warning('off');

setzoomstate(this.FigureHandle);

warning(w);

% [EOF]
