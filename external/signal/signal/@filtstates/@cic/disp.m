function disp(this)
%DISP   Object Display.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

s = dispstr(this);

f1 = find(s == newline, 1 );

s = [blanks(4) s(1:f1) blanks(4) s(f1+1:end) newline];

disp(s);

% [EOF]
