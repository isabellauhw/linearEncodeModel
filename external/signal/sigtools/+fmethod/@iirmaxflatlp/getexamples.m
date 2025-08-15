function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass generalized Butterworth IIR filter.', ...
    'h  = fdesign.lowpass(''Nb,Na,F3dB'', 10, 8, 0.3);', ...
    'Hd = design(h, ''butter'');'}};

% [EOF]
