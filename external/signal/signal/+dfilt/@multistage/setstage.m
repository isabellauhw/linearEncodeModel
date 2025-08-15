function setstage(this, Hd, pos)
%SETSTAGE   Set the stage.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(3,3);

s = this.Stage;
s(pos) = Hd;
this.Stage = s;

% [EOF]
