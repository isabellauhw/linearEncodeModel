function this = lpnorm(varargin)
%LPNORM Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = fdadesignpanel.lpnorm;

f = '[0 0.37 0.399 0.401 0.43 1]';
set(this, 'FreqUnits', 'normalized', ...
    'FrequencyVector', f, 'FrequencyEdges', f);

% [EOF]
