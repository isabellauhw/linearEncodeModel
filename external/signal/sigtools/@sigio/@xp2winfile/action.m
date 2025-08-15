function success = action(hCD)
%ACTION Perform the action of exporting to a window text-file.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

winwrite(array(hCD.data));

success = true;

% [EOF]
