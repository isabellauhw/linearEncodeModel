function resetaxes(hAx)
% Delete all the children of the axes and reset the axes.
%
%   Inputs:
%   hAx -   Handle to the axes

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

delete(allchild(hAx));
reset(hAx);

% [EOF]
