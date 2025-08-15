function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Copyright 1999-2015 The MathWorks, Inc.

args = {hs.FilterOrder, [0 hs.Fpass1 hs.Fstop1 hs.Fstop2 hs.Fpass2 1], ...
    [1 1 0 0 1 1], [this.Wpass1 this.Wstop this.Wpass2]};

% [EOF]
