function b = actualdesign(this, hs)
%ACTUALDESIGN   Design a least squares filter.

%   Copyright 1999-2015 The MathWorks, Inc.

args = designargs(this, hs);

b = {firls(args{:})};

% [EOF]
