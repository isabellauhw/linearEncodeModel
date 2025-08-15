function prop = getpositionproperty(this, c)
%GETPOSITIONPROPERTY   Get the positionproperty.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if ishghandle(c, 'axes')
    prop = 'OuterPosition';
else
    prop = 'Position';
end

% [EOF]
