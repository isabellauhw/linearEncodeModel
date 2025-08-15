function setstate(this, state)
%SETSTATE   Set the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

this.Data = state;
this.SelectedFilters = [];

send(this, 'NewData');

% [EOF]
