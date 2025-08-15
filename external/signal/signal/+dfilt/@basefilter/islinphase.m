function f = islinphase(Hb, varargin)
%ISLINPHASE  True for linear phase filter.
%   ISLINPHASE(Hb) returns 1 if filter Hb is linear phase, and 0 otherwise.
%
%   ISLINPHASE(Hb,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.

%   Copyright 1988-2018 The MathWorks, Inc.

narginchk(1,2);

f = base_is(Hb, 'thisislinphase', varargin{:});

% [EOF]
