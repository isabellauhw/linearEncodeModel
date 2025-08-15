function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandstop Chebyshev type II filter in the DF2SOS structure.', ...
    'h  = fdesign.bandstop(''N,Fst1,Fst2,Ast'');', ...
    'Hd = design(h, ''cheby2'', ''FilterStructure'', ''df2sos'');'}};


% [EOF]
