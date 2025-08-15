function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Get the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g)
    
    [upper, lower, strs] = setstrs(h);
    
    set(h, upper, get(g, 'UpperValues')');
    set(h, lower, get(g, 'LowerValues')');
end

% [EOF]
