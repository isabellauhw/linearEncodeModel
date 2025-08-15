function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN Design the filter

%   Copyright 1999-2015 The MathWorks, Inc.

hd=fdesign.rcosine;
hd.Specification = 'N,Beta';

b = rcosmindesign(this, hspecs, 'normal', hd);

% [EOF]
