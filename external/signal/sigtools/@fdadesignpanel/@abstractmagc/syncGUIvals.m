function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Sync values from frame.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g)
    
    set(h, 'ConstrainedBands', get(g, 'ConstrainedBands'));
    set(h, 'MagUnits', get(g, [get(h, 'IRType') 'units']));
    
    set(h, setstrs(h), get(g, 'Value')');

end

% [EOF]
