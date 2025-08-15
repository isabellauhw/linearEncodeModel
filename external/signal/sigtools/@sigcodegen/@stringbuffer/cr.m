function cr(this)
%CR Adds a carriage return.
%   H.CR Adds a carriage return to the string buffer.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

this.buffer = [this.buffer {''}];

% [EOF]