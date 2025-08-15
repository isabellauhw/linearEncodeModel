function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandstop Elliptic filter in the DF2SOS structure.', ...
    'h  = fdesign.bandstop(''N,Fp1,Fp2,Ap,Ast'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df2sos'');'}};

% [EOF]
