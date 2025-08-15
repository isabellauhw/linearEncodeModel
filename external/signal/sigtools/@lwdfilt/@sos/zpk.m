function [z,p,k] = zpk(this)
%ZPK  Discrete-time filter zero-pole-gain conversion.
%   [Z,P,K] = ZP(this) returns the zeros, poles, and gain corresponding to the
%   discrete-time filter this in vectors Z, P, and scalar K respectively.
%
%   See also DFILT.   
  
%   Author: R. Losada, J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

sosm = get(this, 'SOSMatrix');

nsecs = size(sosm, 1);

if length(this.ScaleValues) > nsecs + 1
    warning(message('signal:lwdfilt:sos:zpk:scalevalues', nsecs + 1));
end

z = [];
p = [];
k = prod(this.ScaleValues);
for indx = 1:size(sosm,1)
  [z1,p1,k1] = sos2zp(sosm(indx,:));
  z = [z;z1];
  p = [p;p1];
  k = k*k1;
end

% [EOF]
