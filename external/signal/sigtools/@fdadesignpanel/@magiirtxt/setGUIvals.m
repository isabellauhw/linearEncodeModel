function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the gui values

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

frames = whichframes(h);
g = findhandle(h, frames{:});

set(g, 'Text', {getString(message('signal:sigtools:fdadesignpanel:Theattenuationatcutoffhalfthepassbandpower'))});

% [EOF]
