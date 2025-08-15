function str = filtertype_getstatefield(hObj)
%GETSTATEFIELD Return the field for the state

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

str = get(classhandle(hObj), 'Name');
str = {str(1:2)};

% [EOF]
