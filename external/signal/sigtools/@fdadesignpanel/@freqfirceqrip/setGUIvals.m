function setGUIvals(this, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = findhandle(this, whichframes(this));

if ~isempty(h)
    set(h, 'Fs', get(this, 'Fs'));
    set(h, 'Units', get(this, 'FreqUnits'));
    set(this.WhenRenderedListeners, 'Enabled', 'Off');
    set(h, 'FreqSpecType', get(this, 'FreqSpecType'));
    set(this.WhenRenderedListeners, 'Enabled', 'On');
    
    name = getdynamicname(h);
    set(h, name, get(this, name));
end

% [EOF]
