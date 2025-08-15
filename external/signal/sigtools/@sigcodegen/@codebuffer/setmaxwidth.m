function width = setmaxwidth(this, width)
%SETMAXWIDTH Set Function for the maximum width property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

str = this.string;
this.clear;
this.add(str);

% [EOF]
