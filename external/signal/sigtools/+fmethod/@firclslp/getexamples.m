function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a lowpass constrained least-squares FIR filter.', ...
    'h  = fdesign.lowpass(''N,Fc,Ap,Ast'', 50, 0.3, 2, 30);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]