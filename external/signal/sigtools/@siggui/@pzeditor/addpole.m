function hP = addpole(hObj, cp)
%ADDPOLE Add a pole to the filter

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hP = privadd(hObj, cp, 'pole');

% [EOF]
