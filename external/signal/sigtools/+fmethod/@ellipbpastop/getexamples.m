function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Elliptic filter in the DF2TSOS structure.', ...
    'h  = fdesign.bandpass(''N,Fp1,Fp2,Ast1,Ap,Ast2'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
