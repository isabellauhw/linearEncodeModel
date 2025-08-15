function help_scalepassband(this)
%HELP_SCALEPASSBAND   

%   Copyright 1999-2015 The MathWorks, Inc.

scale_str = sprintf('%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''ScalePassband'', SCALE) scales the first passband so', ...
    '    that it has a magnitude of 0 dB after windowing when SCALE is TRUE.', ...
    '    SCALE is TRUE by default.');

disp(scale_str);
disp(' ');

% [EOF]
