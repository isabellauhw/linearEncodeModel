function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass Chebyshev type I filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,Fp,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
