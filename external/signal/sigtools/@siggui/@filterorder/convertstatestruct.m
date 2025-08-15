function sout = convertstatestruct(h, sin)
%CONVERTSTATESTRUCT Convert the old state structure to the new state format

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

sout.mode  = sin.order.calc(1:7);
sout.order = sin.order.value{1};

% [EOF]
