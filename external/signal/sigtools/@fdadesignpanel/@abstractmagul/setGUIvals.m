function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g)

    [upper, lower, strs] = setstrs(h);
    
    set(g, 'Labels', strs);
    set(g, 'UpperValues', get(h, upper));
    set(g, 'LowerValues', get(h, lower));

end

% [EOF]
