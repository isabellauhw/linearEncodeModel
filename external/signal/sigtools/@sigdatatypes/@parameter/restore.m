function restore(hPrm)
%RESTORE Restore the default value

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

setvalue(hPrm, get(hPrm, 'DefaultValue'));

% [EOF]
