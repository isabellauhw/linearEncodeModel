function s = getstate(h)
%GETSTATE Get the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

s = siggui_getstate(h);
s = rmfield(s, 'Name');

% [EOF]
