function h = hpfreqifir
%HPFREQIFIR

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

h = fdadesignpanel.hpfreqifir;

set(h, 'Fstop', '2880');
set(h, 'Fpass', '3360');

% [EOF]
