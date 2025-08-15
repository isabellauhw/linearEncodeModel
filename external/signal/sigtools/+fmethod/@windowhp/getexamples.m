function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass Windowed FIR filter with a Kaiser window.', ...
    'h  = fdesign.highpass(''N,Fc'', 30);', ...
    'Hd = design(h, ''window'', ''Window'', {@kaiser, .45});'}};

% [EOF]
