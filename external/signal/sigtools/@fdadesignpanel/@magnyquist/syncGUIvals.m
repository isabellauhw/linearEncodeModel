function syncGUIvals(this, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = findhandle(this, whichframes(this));

if ~isempty(h)
    set(this, 'DesignType', map(get(h, 'CurrentSelection')));
end

% ------------------------------------------------------
function dt = map(dt)

if strcmpi(dt, 'minimum-phase')
    dt = 'minphase';
end

% [EOF]
