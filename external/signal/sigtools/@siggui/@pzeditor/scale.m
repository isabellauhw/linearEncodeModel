function scale(hObj, factor)
%SCALE Scale by a factor
%   SCALE(hPZ, FACTOR) Scale the current Pole/Zero by FACTOR

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,2);

hPZ = get(hObj, 'CurrentRoots');

setvalue(hPZ, double(hPZ)*factor);

% [EOF]
