function boolflag = isrendered(h)
%ISRENDERED Returns true if the render method has been called

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

boolflag = ~isempty(findprop(h,'RenderedPropHandles'));

% [EOF]
