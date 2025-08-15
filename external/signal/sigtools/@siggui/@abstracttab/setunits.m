function setunits(this, units)
%SETUNITS   PreSet function for the 'units' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

h = convert2vector(this.TabHandles);
set(h, 'Units', units);

siggui_setunits(this, units);

h = allchild(this);
for indx = 1:length(h)
    setunits(h(indx), units);
end

% [EOF]
