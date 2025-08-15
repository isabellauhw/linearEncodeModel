function c = cparam(h)
%CPARAM   

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.

F1 = h.F3dB1;
F2 = h.F3dB2;
c = computecparam(h,F1,F2);


% [EOF]
