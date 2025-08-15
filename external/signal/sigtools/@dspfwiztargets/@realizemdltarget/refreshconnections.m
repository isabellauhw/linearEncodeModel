function refreshconnections(hTar)
%REFRESHCONNECTIONS refresh system connections

%   Copyright 2009 The MathWorks, Inc.

sys = hTar.system;
oldpos = get_param(sys, 'Position');
set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
set_param(sys, 'Position', oldpos);

% [EOF]
