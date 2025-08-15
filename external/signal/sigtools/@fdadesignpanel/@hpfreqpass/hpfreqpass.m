function this = hpfreqpass
%HPFREQPASS  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

this = fdadesignpanel.hpfreqpass;
set(this, 'FPass', '14400'); %Use a different default

% [EOF]
