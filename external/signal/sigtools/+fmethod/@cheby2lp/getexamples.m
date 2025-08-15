function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass Chebyshev type II filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,Fst,Ast'');', ...
    'Hd = design(h, ''cheby2'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
