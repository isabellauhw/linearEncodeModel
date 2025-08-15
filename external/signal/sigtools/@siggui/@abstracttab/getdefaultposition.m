function defaultposition = getdefaultposition(this)
%GETDEFAULTPOSITION   Returns the default position for the tabs.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

sz = gui_sizes(this);
defaultposition = [10 10 300 200]*sz.pixf;

% [EOF]
