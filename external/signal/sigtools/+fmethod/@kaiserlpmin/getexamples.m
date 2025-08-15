function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass Kaiser windowed FIR filter.', ...
    'h  = fdesign.lowpass(''Fp,Fst,Ap,Ast'');', ...
    'Hd = design(h, ''kaiserwin'', ''ScalePassband'', false);'}};

% [EOF]
