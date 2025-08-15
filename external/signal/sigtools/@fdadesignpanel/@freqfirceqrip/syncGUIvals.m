function syncGUIvals(hObj, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = findhandle(hObj, whichframes(hObj));

if ~isempty(h)
    set(hObj, 'Fs', get(h, 'Fs'));
    set(hObj, 'FreqUnits', get(h, 'Units'));
    set(hObj, 'FreqSpecType', get(h, 'FreqSpecType'));

    name = getdynamicname(h);
    set(hObj, name, get(h, name));
end

% [EOF]
