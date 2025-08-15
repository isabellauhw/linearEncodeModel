function thisunrender(this)
%THISUNRENDER Unrender the container and its components

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%     o

delete(handles2vector(this));

% Unrender all the children
for hindx = allchild(this)
    unrender(hindx);
end

delete(this.Container);

% [EOF]
