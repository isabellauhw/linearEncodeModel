function [q,k] = computeq2(this,N,D)
%COMPUTEQ2   Alternate algorithm to compute q

%   Copyright 1999-2015 The MathWorks, Inc.

q = (1/16*(1/D))^(1/N);
qr=roots([150 0 0 0 15 0 0 0 2 0 0 0 1 -q]);
indx = find(imag(qr) == 0); % Find real root
q0 = qr(indx);
k1=((1-2*q0)/(1+2*q0))^2;
k = sqrt(1-k1^2);

% [EOF]
