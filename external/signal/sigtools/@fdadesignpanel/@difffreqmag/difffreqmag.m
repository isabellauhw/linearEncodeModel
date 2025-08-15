function this = difffreqmag
%DIFFFREQMAG  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = fdadesignpanel.difffreqmag;

% Set the defaults for the differentiator freqmag frame
set(this, 'FreqUnits', 'normalized', ...
    'FrequencyVector', '[0 .5 .55 1]', ...
    'MagnitudeVector', '[0 1 0 0]', ...
    'WeightVector',    '[1 1]');

% [EOF]
