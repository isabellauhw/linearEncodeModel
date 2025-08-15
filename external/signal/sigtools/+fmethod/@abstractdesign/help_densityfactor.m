function help_densityfactor(this, dfactor)
%HELP_DENSITYFACTOR   

%   Copyright 1999-2015 The MathWorks, Inc.

if nargin < 2
    dfactor = 16;
end

density_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''DensityFactor'', DENS) specifies the grid density DENS', ...
    sprintf('    used in the optimization.  DENS is %d by default.', dfactor));

disp(density_str);
disp(' ');

% [EOF]
