function p = propstoadd(this)
%PROPSTOADD   Return the properties to add to the parent object.

%   Copyright 2005 The MathWorks, Inc.

p = propstoadd(this.CurrentSpecs);

p = {'Description', p{:}};

% [EOF]
