function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass Equiripple filter in a transposed structure.', ...
    'h  = fdesign.lowpass(''Fp,Fst,Ap,Ast'');', ...
    'Hd = design(h, ''equiripple'', ''FilterStructure'', ''dffirt'');'}};

% [EOF]
