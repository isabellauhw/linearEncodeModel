function destroy(h)
%DESTROY Delete the SIGGUI object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if isrendered(h)
    unrender(h);
end

delete(h);
clear h

% [EOF]
