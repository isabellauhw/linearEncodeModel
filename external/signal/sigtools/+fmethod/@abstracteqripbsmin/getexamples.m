function examples = getexamples(~)
%GETEXAMPLES Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Equiripple filter in a transposed structure.', ...
    'h  = fdesign.bandstop(''Fp1,Fst1,Fst2,Fp2,Ap1,Ast,Ap2'');', ...
    'Hd = design(h, ''equiripple'', ''FilterStructure'', ''dffirt'');'}};

% [EOF]
