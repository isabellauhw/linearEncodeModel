function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass Kaiser windowed FIR filter.', ...
    'h  = fdesign.highpass(''Fst,Fp,Ast,Ap'');', ...
    'Hd = design(h, ''kaiserwin'', ''ScalePassband'', false);'}};

% [EOF]
