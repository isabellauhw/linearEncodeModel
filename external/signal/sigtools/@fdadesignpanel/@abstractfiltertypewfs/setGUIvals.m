function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the GUI vals of the fsspecifier

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs)

    % Cache the fs so that the set on Units does not overwrite it.
    set(hfreqspecs, 'Units', get(h,'FreqUnits'));
    set(hfreqspecs, 'Fs', get(h, 'Fs'));
    
    [strs, lbls] = setstrs(h);
    
    set(hfreqspecs, 'Values', get(h, strs));
    set(hfreqspecs, 'Labels', lbls);
    
end

% [EOF]
