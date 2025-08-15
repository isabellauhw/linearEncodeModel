function b = hashelp(this)
%HASHELP   Returns true if there is a CSHelpTag.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% We only have help if a tag was provided.
b = ~isempty(this.CSHelpTag);

% [EOF]
