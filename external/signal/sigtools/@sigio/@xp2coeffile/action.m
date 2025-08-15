function success = action(hCD)
%ACTION Perform the action of exporting to a filter coefficient file.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.

fcfwrite(array(hCD.data), [], hCD.Format(1:3));

success = true;

% [EOF]
