function fh = getfrheight(h)
%GETFRHEIGHT Get frame height.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

sz = gui_sizes(h);
fh = 100*sz.pixf;        

% [EOF]
