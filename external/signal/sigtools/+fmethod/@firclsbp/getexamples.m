function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandpass constrained least-squares FIR filter.', ...
    'h  = fdesign.bandpass(''N,Fc1,Fc2,Ast1,Ap,Ast2'', 50, 0.3, 0.6, 30, 1, 50);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]