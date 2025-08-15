function empty(hStack)
%EMPTY Empties the stack

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

% Clear out the stack
set(hStack,'Data',{});

% Notify listeners
send(hStack,'TopChanged',handle.EventData(hStack,'TopChanged'));

% [EOF]
