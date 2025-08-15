function sc = scalecheck(Hd,pnorm)
%SCALECHECK   

%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2
    pnorm = 'Linf';
end
sc = df2df1tscalecheck(Hd,pnorm);

% [EOF]
