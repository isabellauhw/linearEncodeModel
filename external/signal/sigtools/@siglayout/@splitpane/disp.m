function disp(this)
%DISP   Display this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if this.AutoUpdate
    dispstr = 'true';
else
    dispstr = 'false';
end

disp(changedisplay(get(this), 'AutoUpdate', dispstr));

% [EOF]
