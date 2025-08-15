function setGUIvals(hObj, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = findhandle(hObj, whichframes(hObj));

if ~isempty(h)
    set(h, 'Units', get(hObj, 'FreqUnits'));
    set(h, 'Fs', get(hObj, 'Fs'));
    
    if strncmpi(h.Units, 'normalized', 10)
        text = {'wc    =    1/2'};
    else
        text = {'Fc    =    Fs/4'};
    end
    
    set(h, 'Text', text);
end

% [EOF]
