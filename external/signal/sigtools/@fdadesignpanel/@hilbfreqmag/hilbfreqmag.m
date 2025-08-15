function this = hilbfreqmag
%HILBFREQMAG  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = fdadesignpanel.hilbfreqmag;

% Set the defaults for the Hilbert Transformer FreqMag frame
set(this, 'FreqUnits', 'normalized', ...
    'FrequencyVector', '[0.05 0.95]', ...
    'MagnitudeVector', '[1 1]', ...
    'WeightVector',    '[1]');

% [EOF]
