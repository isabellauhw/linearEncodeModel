function [num,a1,w0] = cheby1coeffs(h,N,wp,rp)
%CHEBY1COEFFS   

%   Copyright 1999-2015 The MathWorks, Inc.


[cs,theta] = costheta(h,N);

ss = sin(theta);

a = 1/N*asinh(1/sqrt(10^(rp/10)-1));

w0 = wp*sinh(a);

wi = wp*ss;

num = w0^2+wi.^2;

c = 2*w0;
a1 = -c*cs;

% [EOF]
