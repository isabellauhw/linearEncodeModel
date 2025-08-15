function str  = getstatefield(hObj)
%GETSTATEFIELD Return fields names for the state structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

str    = filtertype_getstatefield(hObj);
str{2} = 'cutoff';

% [EOF]
