function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Butterworth filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,F3dB1,F3dB2'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df1sos'');'}};

% [EOF]
