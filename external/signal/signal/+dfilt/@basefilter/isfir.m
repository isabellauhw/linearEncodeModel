function f = isfir(Hb)
%ISFIR  True for FIR filter.
%   ISFIR(Hb) returns 1 if filter Hd is FIR, and 0 otherwise.
%
%   See also DFILT.   
  
%   Copyright 1988-2018 The MathWorks, Inc.

f = base_is(Hb, 'thisisfir');

% [EOF]
