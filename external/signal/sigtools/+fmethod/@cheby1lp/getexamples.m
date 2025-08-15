function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass Chebyshev type I filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,Fp,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
