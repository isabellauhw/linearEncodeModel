function this = iirlpnorm
%IIRLPNORM  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = fdadesignpanel.iirlpnorm;

% Set the defaults for the arbitrary magnitude freqmag frame
set(this, 'FreqUnits', 'normalized', ...
    'FrequencyVector', '[0:.0005:.0175 .02 .0215 .025 1]', ...
    'FrequencyEdges',  '[0 .0175 .02 .0215 .025 1]', ...
    'MagnitudeVector', '[.4845./(1-((0:.0005:.0175)./0.0179).^2).^.025 0 0 0 0]', ...
    'WeightVector',    '[ones(1,39) 300]');

% [EOF]
