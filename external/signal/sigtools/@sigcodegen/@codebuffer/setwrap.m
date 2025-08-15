function wrap = setwrap(this, wrap)
%SETWRAP Set Function for the public wrap

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

str = this.string;
this.clear;
this.add(str);

% [EOF]
