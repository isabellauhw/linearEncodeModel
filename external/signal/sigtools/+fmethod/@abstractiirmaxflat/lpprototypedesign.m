function [b, a] = lpprototypedesign(this, hspecs, varargin)
%LPPROTOTYPEACTUALDESIGN   Design the prototype lowpass IIR filter which
%   will be used for maxflat design of highpass, bandpass and bandstop
%   filters by frequency transformation.

%   Copyright 1999-2015 The MathWorks, Inc.

% Calculate the coefficients using the MAXFLAT function. 
args = designargs(this, hspecs);
[b,a] = maxflat(args{:}, varargin{:});

% [EOF]
