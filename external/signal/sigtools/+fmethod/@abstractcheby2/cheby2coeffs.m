function [b0,a1,a0,w0,c0] = cheby2coeffs(h,N,ws,rs)
%CHEBY2COEFFS   

%   Copyright 1999-2015 The MathWorks, Inc.

[cs,theta] = costheta(h,N);

ss = sin(theta);

a = 1/N*asinh(sqrt(10^(rs/10)-1));

w0 = ws/sinh(a);

wi = ws./ss;

b0 = wi.^(-2);

a0 = b0+w0.^(-2);

c0 = w0^(-1)*cs;

a1 = -2*c0;



% [EOF]
