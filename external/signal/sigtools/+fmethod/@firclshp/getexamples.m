function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a highpass constrained least-squares FIR filter.', ...
    'h  = fdesign.highpass(''N,Fc,Ast,Ap'', 50, 0.3, 30, 2);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]