function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Copyright 1999-2015 The MathWorks, Inc.


TWn = hs.TransitionWidth/2;

args = {hs.FilterOrder, [TWn 1-TWn], [1 1],'hilbert'};

% [EOF]
