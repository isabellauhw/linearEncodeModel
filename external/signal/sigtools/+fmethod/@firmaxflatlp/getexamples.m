function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass maximally flat FIR filter.', ...
    'h  = fdesign.lowpass(''N,F3dB'', 50, 0.3);', ...
    'Hd = design(h, ''maxflat'');'}};

% [EOF]