function [N,F,E,A,P,nfpts] = getvalidspecs(this,hspecs)
%GETVALIDSPECS   Get the validspecs.

%   Copyright 1999-2015 The MathWorks, Inc.

% Validate specifications
[N,F,E,H,nfpts] = validatespecs(hspecs);
A = abs(H);
P = angle(H);


% [EOF]
