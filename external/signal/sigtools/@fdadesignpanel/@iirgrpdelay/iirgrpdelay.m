function this = iirgrpdelay
%LPNORM Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = fdadesignpanel.iirgrpdelay;

set(this, 'FreqUnits', 'normalized', ...
    'FrequencyVector', '[0 0.1 1]', ...
    'FrequencyEdges', '[0 1]');

% [EOF]
