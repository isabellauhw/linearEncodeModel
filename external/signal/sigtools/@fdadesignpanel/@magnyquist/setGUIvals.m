function setGUIvals(this, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = findhandle(this, whichframes(this));

if ~isempty(h)
    set(h, 'AllOptions', mapall(set(this, 'DesignType')));
    set(h, 'CurrentSelection', map(get(this, 'DesignType')));
end

% ---------------------------------------------
function dt = mapall(dt)

dt{3} = 'Minimum-Phase';

% ---------------------------------------------
function dt = map(dt)

if strcmpi(dt, 'minphase')
    dt = 'Minimum-phase';
end

% [EOF]
