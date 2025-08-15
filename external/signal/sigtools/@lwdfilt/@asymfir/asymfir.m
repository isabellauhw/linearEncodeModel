function H = asymfir(num)
%ASYMFIR   Construct a ASYMFIR object.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

H = lwdfilt.asymfir;

if nargin > 0
    H.Numerator = num;
    H.refnum = num;
end

% [EOF]
