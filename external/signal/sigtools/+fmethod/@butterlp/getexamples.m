function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass Butterworth filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,F3dB'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
