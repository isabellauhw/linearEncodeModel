function s = getstate(this)
%GETSTATE Get the state of the object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

s = sigcontainer_getstate(this);
s = rmfield(s, 'Data');
s = rmfield(s, 'Destination');

% [EOF]
