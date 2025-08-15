function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass Elliptic filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,Fp,Fst,Ap'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
