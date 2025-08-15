function b = lpprototypedesign(this, hspecs, varargin)
%LPPROTOTYPEDESIGN   Design the prototype lowpass maximally flat FIR which
%   will used for frequency transformation.

%   Copyright 1999-2015 The MathWorks, Inc.

args = designargs(this, hspecs);

% Calculate the coefficients using the MAXFLAT function.
b  = {maxflat(args{1}, 'sym', args{2})};

% [EOF]
