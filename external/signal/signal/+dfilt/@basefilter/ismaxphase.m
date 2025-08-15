function f = ismaxphase(Hb, varargin)
%ISMAXPHASE True if maximum phase.
%   ISMAXPHASE(Hb) returns 1 if filter Hb is maximum phase, and 0 otherwise.
%
%   ISMAXPHASE(Hb,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Copyright 1988-2018 The MathWorks, Inc.

narginchk(1,2);

f = base_is(Hb, 'thisismaxphase', varargin{:});

% [EOF]
