function varargout = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN   Design the maximally flat lowpass IIR filter

%   Copyright 1999-2015 The MathWorks, Inc.

[b,a] = lpprototypedesign(this, hspecs, varargin{:});
[sos, g] = tf2sos(b,a);
varargout = {{sos, g}};

% [EOF]

