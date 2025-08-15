function poles = fdToPoles(fn,dr)
%FDTOPOLES Compute poles from natural frequency and damping.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

% Compute complex poles for the natural frequencies fr and the damping
% ratios dr
wn = 2*pi*fn;
poles = -dr.*wn+1i*wn.*sqrt(1-dr.^2);