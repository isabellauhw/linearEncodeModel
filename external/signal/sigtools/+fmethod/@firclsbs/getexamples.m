function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 1999-2015 The MathWorks, Inc.

examples = {{ ...
    'Design a bandstop constrained least-squares FIR filter.', ...
    'h  = fdesign.bandstop(''N,Fc1,Fc2,Ap1,Ast,Ap2'', 50, 0.3, 0.6, 2, 40, 1);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]