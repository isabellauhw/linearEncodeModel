function sc = scalecheck(Hd,pnorm)
%SCALECHECK   

%   Author(s): R. Losada
%   Copyright 1988-2018 The MathWorks, Inc.


if nargin > 1
    pnorm = convertStringsToChars(pnorm);
end

sc = df1df2tscalecheck(Hd,pnorm);

% [EOF]
