function varargout = actualdesign(this, hspecs)
%ACTUALDESIGN   Perform the actual design.

%   Copyright 1999-2015 The MathWorks, Inc.

args = designargs(this, hspecs);

varargout{1:nargout} = {fircls(args{:})};
% [EOF]
