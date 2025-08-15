function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Chebyshev type II filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,Fst1,Fst2,Ast'');', ...
    'Hd = design(h, ''cheby2'', ''FilterStructure'', ''df1sos'');'}};


% [EOF]
