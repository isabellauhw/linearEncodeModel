function current = get_current(this, current)
%GET_CURRENT   PreGet function for the 'current' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

current = get(this, 'privCurrentFilter');

% [EOF]
