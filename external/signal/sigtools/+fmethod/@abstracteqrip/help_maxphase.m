function help_maxphase(this)
%HELP_MINPHASE   

%   Copyright 1999-2015 The MathWorks, Inc.

maxphase_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''MaxPhase'', MPHASE) designs a maximum-phase filter', ...
    '    when MPHASE is TRUE.  MPHASE is FALSE by default.');

disp(maxphase_str);
disp(' ');


% [EOF]