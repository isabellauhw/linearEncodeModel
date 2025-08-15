function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandstop Butterworth filter in the DF2SOS structure.', ...
    'h  = fdesign.bandstop(''N,F3dB1,F3dB2'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df2sos'');'}};

% [EOF]
