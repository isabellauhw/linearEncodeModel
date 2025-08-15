function setstate(h, s)
%SETSTATE Set the state of the selector object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

set(h, 'Selection', s.Selection);
set(h, 'SubSelection', s.SubSelection);

% [EOF]
