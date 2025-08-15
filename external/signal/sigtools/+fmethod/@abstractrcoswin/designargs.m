function args = designargs(this, hspecs)
%DESIGNARGS Return the arguments for the design method
%   OUT = DESIGNARGS(ARGS) <long description>

%   Copyright 1999-2015 The MathWorks, Inc.

N = getFilterOrder(hspecs);

args = {N, hspecs.RolloffFactor, hspecs.SamplesPerSymbol};

% [EOF]
