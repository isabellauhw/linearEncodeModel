function resetoperations(this)
%RESETOPERATIONS Reset the operations

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

s = getstate(this);
c = allchild(this);

for indx = 1:length(c)
    n{indx} = get(classhandle(c(indx)), 'Name');
end

set(this, 'PreviousState', rmfield(s, n));

% [EOF]
