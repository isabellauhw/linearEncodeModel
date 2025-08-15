function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass Windowed FIR filter with a Kaiser window.', ...
    'h  = fdesign.bandpass(''N,Fc1,Fc2'', 30);', ...
    'Hd = design(h, ''window'', ''Window'', {@kaiser, .4});'}};

% [EOF]
