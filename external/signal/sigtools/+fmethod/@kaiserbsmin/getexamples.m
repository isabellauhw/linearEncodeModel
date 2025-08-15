function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandstop Kaiser windowed FIR filter.', ...
    'h  = fdesign.bandstop(''Fp1,Fst1,Fst2,Fp2,Ap1,Ast,Ap2'');', ...
    'Hd = design(h, ''kaiserwin'', ''ScalePassband'', false);'}};

% [EOF]
