function signalLabeler(varargin)
%SIGNALLABELER Label signal attributes, regions, and points of interest
%   SIGNALLABELER opens the Signal Labeler app.

%   Copyright 2019 The MathWorks, Inc.

nargoutchk(0,0);
narginchk(0,0);
signal.labeler.signalLabelerImpl();
end