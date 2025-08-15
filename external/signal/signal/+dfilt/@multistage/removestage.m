function removestage(this, indx)
%REMOVESTAGE   Remove a stage.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(2,2);

s = this.Stage;
s(indx) = [];

this.Stage = s;

% [EOF]
