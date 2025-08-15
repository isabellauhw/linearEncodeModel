function d = lines(this)
%LINES Returns the number of lines of text.
%   H.LINES Returns the number of lines in the string buffer.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

d = length(this.buffer);

% [EOF]