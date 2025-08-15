function has = analogspecsword(h,hs)
%ANALOGSPECSWORD   Compute an analog specifications object from a
%digital specifications object with filter order.

%   Copyright 1999-2015 The MathWorks, Inc.

% Compute analog response type object
has = analogresp(hs);

% [EOF]
