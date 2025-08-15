function varargout = invertunitcircle(hObj)
%INVERTUNITCIRCLE Invert about the unit circle.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

newvalue = conj(1./double(hObj));

if nargout
    varargout = {newvalue};
else
    setvalue(hObj, newvalue);
end

% [EOF]
