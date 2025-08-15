function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN <short description>
%   OUT = ACTUALDESIGN(ARGS) <long description>

%   Copyright 1999-2015 The MathWorks, Inc.

args = designargs(this, hspecs);

N = args{1};
BT = args{2};
sps = args{3};

b = {gaussfir(BT,N/(2*sps),sps)};

% [EOF]
