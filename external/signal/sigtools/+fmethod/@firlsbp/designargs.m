function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Copyright 1999-2015 The MathWorks, Inc.

args = {hs.FilterOrder, [0 hs.Fstop1 hs.Fpass1 hs.Fpass2 hs.Fstop2 1], ...
    [0 0 1 1 0 0], [this.Wstop1 this.Wpass this.Wstop2]};

% [EOF]
