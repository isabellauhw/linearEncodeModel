function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass Elliptic filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,Fp,Ast,Ap'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
