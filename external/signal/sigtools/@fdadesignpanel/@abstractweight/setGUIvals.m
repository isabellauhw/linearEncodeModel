function setGUIvals(h,eventData) %#ok
%SETGUIVALS Set values from object in GUI.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g)
    
    [strs, lbls] = setstrs(h);
    
    set(g,'Values', get(h,strs));
    set(g,'Labels', lbls);
end

% [EOF]
