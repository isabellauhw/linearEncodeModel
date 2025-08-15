function help_force(~)
%HELP_FORCE   

%   Copyright 1999-2015 The MathWorks, Inc.

force_str = sprintf('%s\n%s\n\n%s\n\n%s', ...
    '    HD = DESIGN(..., ''MinOrder'', ''any'') designs a minimum-order filter.', ...
    '    The order of the filter can be even or odd. This is the default.', ...  
    '    HD = DESIGN(..., ''MinOrder'', ''even'') designs a minimum-even-order filter.', ...
    '    HD = DESIGN(..., ''MinOrder'', ''odd'') designs a minimum-odd-order filter.');

disp(force_str);
disp(' ');

% [EOF]
