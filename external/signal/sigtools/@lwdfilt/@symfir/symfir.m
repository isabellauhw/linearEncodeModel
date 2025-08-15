function H = symfir(num)
%SYMFIR   Construct a SYMFIR object.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

H = lwdfilt.symfir;

if nargin > 0
    H.Numerator = num;
    H.refnum = num;
end

% [EOF]
