function rotate(hObj, R)
%ROTATE Rotate Pole/Zero
%   ROTATE(hOBJ, R) Rotate the current Pole/Zero by R radians

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hPZ = get(hObj, 'CurrentRoots');

setvalue(hPZ, double(hPZ) * (sin(R)*1i + cos(R)))

updatelimits(hObj);

% [EOF]
