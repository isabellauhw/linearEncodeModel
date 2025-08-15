function magunits = getmagunitstrs
%GETMAGUNITSTRS Return a cell array of the standard Magnitude Units strings.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.

magunits = {getString(message('signal:sigtools:Magnitude')),...
            getString(message('signal:sigtools:MagnitudedB')),...
            getString(message('signal:sigtools:MagnitudeSquared'))};

% [EOF]
