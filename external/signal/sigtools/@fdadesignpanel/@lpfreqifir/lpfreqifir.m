function h = lpfreqifir
%LPFREQIFIR

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

h = fdadesignpanel.lpfreqifir;

set(h, 'Fpass', '2880');
set(h, 'Fstop', '3360');

% [EOF]
