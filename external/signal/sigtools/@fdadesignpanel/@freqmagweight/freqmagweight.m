function h = freqmagweight
%FREQMAGWEIGHT  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

h = fdadesignpanel.freqmagweight;

set(h, 'FreqUnits', 'normalized');

% [EOF]
