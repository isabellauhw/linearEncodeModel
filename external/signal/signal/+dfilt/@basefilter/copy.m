function Hcopy = copy(this)
%COPY   Copy this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

fun = [class(this) '.loadobj'];
Hcopy = feval(fun,this);

% [EOF]
