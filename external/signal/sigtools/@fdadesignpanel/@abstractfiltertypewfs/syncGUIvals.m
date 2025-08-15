function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs)
    
    set(h, 'FreqUnits', get(hfreqspecs, 'Units'));
    set(h, 'Fs', get(hfreqspecs, 'Fs'));
    
    set(h, setstrs(h), get(hfreqspecs, 'Values')');
end

% [EOF]
