function wf = anom_whichframes(hObj)
%WHICHFRAMES

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

wf = dm_whichframes(hObj);

wf(end+1).constructor = 'siggui.filterorder';
wf(end).setops        = {'Enable', 'Off'};

% Show no options by default
wf(end+1).constructor = 'siggui.textOptionsFrame';
wf(end).setops        = {};

% [EOF]
