function args = designargs(this, hspecs) %#ok<INUSL>
%DESIGNARGS Return the arguments for the design method

%   Copyright 1999-2015 The MathWorks, Inc.

args = {hspecs.Astop, hspecs.RolloffFactor, hspecs.SamplesPerSymbol};

% [EOF]
