function fs = getfs(hFs, eventData)
%GETFS Returns the Sampling Frequency structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

fs = getfs(getcomponent(hFs, '-class', 'siggui.fsspecifier'));

% [EOF]
