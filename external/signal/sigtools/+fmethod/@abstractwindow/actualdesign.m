function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN   Design the lowpass kaiser window.

%   Copyright 1999-2015 The MathWorks, Inc.

args = designargs(this, hspecs);

% Calculate the coefficients using the FIR1 function.
b  = {fir1(args{:})};

% [EOF]
