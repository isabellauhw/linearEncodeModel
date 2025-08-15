function [z,p,k] = zpk(this)
%ZPK  Discrete-time filter zero-pole-gain conversion.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.

[z,p,k] = tf2zpk(this.Numerator,1);