function examples = getexamples(~)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Equiripple filter in a transposed structure.', ...
    'h  = fdesign.bandpass(''Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2'');', ...
    'Hd = design(h, ''equiripple'', ''FilterStructure'', ''dffirt'');'}};

% [EOF]
