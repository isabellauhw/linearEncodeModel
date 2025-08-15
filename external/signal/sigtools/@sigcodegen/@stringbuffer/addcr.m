function addcr(this, varargin)
%ADDCR Adds string with a carriage-return (CR) after it
%   H.ADDCR(STR) adds the string STR to the buffer then a CR.
%
%   H.ADDCR(FMT, VAR1, VAR2, ...) adds the formatted string then a CR.
%
%   See also STRINGBUFFER/ADD, STRINGBUFFER/CRADD, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

str = add_parser(this, varargin{:});

this.add(this.cr_parser(str));
this.cr;

% [EOF]
