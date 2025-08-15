function boolflag = isfull(hStack)
%ISFULL Returns true if the stack is full.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

% Return true if the amount of data is = or > the stack limit
% The > should not be necessary, but it is included as a precaution
boolflag = length(hStack.Data) >= hStack.StackLimit;

% [EOF]
