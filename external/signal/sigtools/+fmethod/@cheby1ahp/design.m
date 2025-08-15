function Ha = design(h,N,wp,rp)
%DESIGN   

%   Copyright 1999-2015 The MathWorks, Inc.

% Compute corresponding lowpass
hlp = fmethod.cheby1alp;
Halp = design(hlp,N,1/wp,rp);

% Transform to highpass
[s,g] = lp2hp(Halp);
Ha = afilt.sos(s,g);

% [EOF]
