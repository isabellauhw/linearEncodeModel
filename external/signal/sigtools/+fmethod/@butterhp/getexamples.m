function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass Butterworth filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,F3dB'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
