function f = isminphase(Hb,varargin)
%ISMINPHASE True if minimum phase.
%   ISMINPHASE(Hb) returns 1 if filter Hb is minimum phase, and 0 otherwise.
%
%   ISMINPHASE(Hb,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Copyright 1988-2018 The MathWorks, Inc.
  
narginchk(1,2);

f = base_is(Hb, 'thisisminphase', varargin{:});

% [EOF]
