function xlbl = getfreqlbl(xunits)
%GETFREQLBL Returns a label for the frequency axis.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

options = getfrequnitstrs;

xlbl = options{1};
for i = length(options):-1:1
    if strfind(options{i}, xunits)
        xlbl = options{i};
    end
end

% [EOF]
