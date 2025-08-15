function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Chebyshev type I filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,Fp1,Fp2,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df1sos'');'}};

% [EOF]
