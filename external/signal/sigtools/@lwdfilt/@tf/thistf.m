function [num,den] = thistf(Hd)
%THISTF  Convert to transfer function.
%   [NUM,DEN] = THISTF(Hd) converts discrete-time filter Hd to numerator and
%   denominator vectors.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.

% This should be private

num = Hd.Numerator;
den = Hd.Denominator;
