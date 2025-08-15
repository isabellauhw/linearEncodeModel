function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass Chebyshev type II filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,Fst,Ast'');', ...
    'Hd = design(h, ''cheby2'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
