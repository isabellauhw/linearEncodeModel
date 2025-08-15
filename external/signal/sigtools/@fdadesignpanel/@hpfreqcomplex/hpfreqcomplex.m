function h = hpfreqcomplex
%LPFREQCOMPLEX Construct an LPFREQCOMPLEX object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

h = fdadesignpanel.hpfreqcomplex;

set(h, 'Fpass1', '-9600');
set(h, 'Fstop1', '-7200');
set(h, 'Fstop2', '12000');
set(h, 'Fpass2', '14400');

% [EOF]
