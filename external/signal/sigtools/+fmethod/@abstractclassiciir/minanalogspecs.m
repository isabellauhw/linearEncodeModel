function has = minanalogspecs(h,hs)
%MINANALOGSPECS   Compute an analog specifications object from a
%minimum-order digital specifications object.

%   Copyright 1999-2015 The MathWorks, Inc.

% Compute analog response type object
hasmin = analogresp(hs);

% Convert from minimum order to specify order
has = tospecifyord(h,hasmin);

% [EOF]
