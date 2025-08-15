function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs)
    
    nonbwlabel = getnonbwlabel(h);
    
    set(h, 'FreqUnits', get(hfreqspecs, 'Units'), ...
        'Fs', get(hfreqspecs, 'Fs'), ...
        'Bandwidth', get(hfreqspecs, 'BandWidth'), ...
        nonbwlabel, get(hfreqspecs, 'NonBW'));
    
    p = setstrs(h);
    if ~isempty(p), set(h, p, get(hfreqspecs, 'Values')'); end
    
    if strcmpi(hfreqspecs.transitionmode, 'nonbw')
        set(h, 'TransitionMode', nonbwlabel);
    else
        set(h, 'TransitionMode', 'Bandwidth');
    end
end

% [EOF]
