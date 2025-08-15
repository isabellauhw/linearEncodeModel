function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the gui values

%   Copyright 1988-2012 The MathWorks, Inc.

frames = whichframes(h);
g = findhandle(h, frames{:});

set(g, 'Text', {getString(message('signal:sigtools:fdadesignpanel:Theattenuationatcutoffhalfthepassbandgain'))});

% [EOF]
