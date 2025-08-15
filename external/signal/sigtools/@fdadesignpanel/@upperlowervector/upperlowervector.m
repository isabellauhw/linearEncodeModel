function h = upperlowervector
%UPPERLOWERVECTOR Construct a UPPERLOWERVECTOR object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

h = fdadesignpanel.upperlowervector;

set(h, 'FreqUnits', 'normalized');
set(h, 'FrequencyVector', '[0 .4 .5 1]');

% [EOF]
