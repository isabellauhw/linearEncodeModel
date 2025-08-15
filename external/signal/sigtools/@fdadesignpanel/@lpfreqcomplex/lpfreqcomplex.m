function h = lpfreqcomplex
%LPFREQCOMPLEX Construct an LPFREQCOMPLEX object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

h = fdadesignpanel.lpfreqcomplex;

set(h, 'Fstop1', '-9600');
set(h, 'Fpass1', '-7200');
set(h, 'Fpass2', '12000');
set(h, 'Fstop2', '14400');

% [EOF]
