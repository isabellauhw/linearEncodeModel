function str = getstatefield(hObj)
%GETSTATEFIELD Return the strings for the state

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

str    = filtertype_getstatefield(hObj);
str{2} = 'passStop';

% [EOF]
