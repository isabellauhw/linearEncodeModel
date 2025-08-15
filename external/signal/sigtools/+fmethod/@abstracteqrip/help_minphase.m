function help_minphase(this)
%HELP_MINPHASE   

%   Copyright 1999-2015 The MathWorks, Inc.

minphase_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''MinPhase'', MPHASE) designs a minimum-phase filter', ...
    '    when MPHASE is TRUE.  MPHASE is FALSE by default.');

disp(minphase_str);
disp(' ');


% [EOF]
