function this = iirlpnormc
%IIRLPNORMC  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

this = fdadesignpanel.iirlpnormc;

% Set the defaults for the IIRLPNORMC specs frame
set(this, 'FrequencyVector', '[0 0.4 0.42 1]', ...
    'FrequencyEdges', '[0 0.4 0.42 1]', ...
    'MagnitudeVector', '[0 0 1 1]', ...
    'WeightVector', '[100 100 1 1]');

% [EOF]
