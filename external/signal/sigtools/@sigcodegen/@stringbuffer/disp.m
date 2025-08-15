function disp(this)
%DISP Display string buffer contents

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

fprintf('%s\n', gettitlestr(this));
fprintf('---------------------------[ Start of buffer ]----------------------------\n');
fprintf('%s', this.string);
if this.lines > 0, fprintf('\n'); end
fprintf('---------------------------[  End of buffer  ]----------------------------\n');

% [EOF]
