function args = designargs(this, hs)
%DESIGNARGS   

%   Copyright 1999-2015 The MathWorks, Inc.

args = {hs.FilterOrder, [0 hs.Fpass hs.Fstop 1], [1 1 0 0], [this.Wpass this.Wstop]};

% [EOF]
