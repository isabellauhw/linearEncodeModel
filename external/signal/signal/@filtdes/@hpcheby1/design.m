function varargout = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

% Set up design params
N = get(d,'order');

[Fpass, Apass] = getdesignspecs(h, d);

if nargout == 1
    hfdesign = fdesign.highpass('N,Fp,Ap', N, Fpass, Apass);
    Hd       = cheby1(hfdesign);
    
    varargout = {Hd};
else

    [z,p,k] = cheby1(N,Apass,Fpass,'high');

    varargout = {z,p,k};
end

% [EOF]
