function thisunrender(this)
%THISUNRENDER   Unrender this object.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.

ht = convert2vector(this.TabHandles);

% Only try to delete the controls that are actual handles.
delete(ht(ishghandle(ht)));
delete(handles2vector(this));

h = allchild(this);

for indx = 1:length(h)
    if isrendered(h(indx)), unrender(h(indx)); end
end

% [EOF]
