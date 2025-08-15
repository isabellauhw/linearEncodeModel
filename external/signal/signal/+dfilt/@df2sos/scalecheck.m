function sc = scalecheck(Hd,pnorm)
%SCALECHECK   

%   Copyright 1988-2018 The MathWorks, Inc.

if nargin > 1
    pnorm = convertStringsToChars(pnorm);
end

if nargin < 2
    pnorm = 'Linf';
end

sc = df2df1tscalecheck(Hd,pnorm);

% [EOF]
