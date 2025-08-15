function setstate(this, state)
%SETSTATE   Set the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if isfield(state, 'DontScale')
    if strcmpi(state.DontScale, 'on')
        state.Scale = 'off';
    else
        state.Scale = 'on';
    end
end

sigcontainer_setstate(this, state);

% [EOF]
