function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Elliptic filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,Fst1,Fp1,Fp2,Fst2,Ap'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df1sos'');'}};

% [EOF]
