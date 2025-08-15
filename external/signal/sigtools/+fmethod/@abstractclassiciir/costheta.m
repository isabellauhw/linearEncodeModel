function [cs,theta] = costheta(h,N)
% Compute cosine of angles of stable poles.
% Used for butterworth, cheby1 and cheby2.

%   Copyright 1999-2015 The MathWorks, Inc.


k = (1:floor(N/2)).';
theta = pi/(2*N)*(N-1+2*k);

cs = cos(theta);
