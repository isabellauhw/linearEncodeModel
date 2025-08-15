function f = isallpass(Hb, varargin)
%ISALLPASS  True for allpass filter.
%   ISALLPASS(Hb) returns 1 if filter Hb is all-pass, and 0 otherwise.
%
%   ISALLPASS(Hb,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Copyright 1988-2018 The MathWorks, Inc.

narginchk(1,2);


f = base_is(Hb, 'thisisallpass', varargin{:});

% [EOF]
