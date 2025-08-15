function h = hpfreqpassstop
%HPFREQPASSSTOP  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

h = fdadesignpanel.hpfreqpassstop;

% Set a new default, we do not want LPFREQSTOP's FactoryValue
set(h, 'Fstop', '9600');

% [EOF]
