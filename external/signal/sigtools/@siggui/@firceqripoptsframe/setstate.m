function setstate(this, state)
%SETSTATE   Set the state.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

set(this, 'IsMinPhase', state.isMinPhase, ...
    'StopbandSlope', state.StopbandSlope);

% [EOF]
