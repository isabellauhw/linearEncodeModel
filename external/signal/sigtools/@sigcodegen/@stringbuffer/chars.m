function d = chars(this)
%CHARS Returns the number of characters of text in the string buffer.
%   H.CHARS Returns the number of characters of text in the string buffer,
%   including carriage returns.
%
%   See also STRINGBUFFER/LINE, STRINGBUFFER/STRING

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

d = length(this.string);

% [EOF]