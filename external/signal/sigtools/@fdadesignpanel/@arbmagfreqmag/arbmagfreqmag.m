function this = arbmagfreqmag
%ARBMAGFREQMAG  Constructor for this object.
%
%   Inputs:
%       FreqVec   - Frequency Vector
%       MagVec    - Magnitude Vector
%       WeightVec - Weight Vector
%       Fs        - Sampling Frequency
%       FreqUnits - Frequency Units ('Hz', 'kHz', etc.)
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = fdadesignpanel.arbmagfreqmag;

% Set the defaults for the differentiator freqmag frame
set(this, 'FreqUnits', 'normalized', ...
    'FrequencyVector', '[0:.05:.55 .6 1]', ...
	'MagnitudeVector', '[1./sinc(0:.05:.55) 0 0]', ...
    'WeightVector',    '[100*ones(1,6) 10]');

% [EOF]
