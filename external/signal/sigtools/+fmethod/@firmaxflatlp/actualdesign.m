function varargout = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN   Design the maximally flat lowpass FIR filter

%   Copyright 1999-2015 The MathWorks, Inc.

[varargout{1:nargout}] = lpprototypedesign(this, hspecs, varargin{:});

% [EOF]
