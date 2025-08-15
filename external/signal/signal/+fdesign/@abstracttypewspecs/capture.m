function capture(this)
%CAPTURE   Capture the state of the object.

%   Copyright 1999-2017 The MathWorks, Inc.

% This should be a protected method.

p = propstocopy(this);

p = [{'Specification'} p];

for indx = 1:length(p)
    c.(p{indx}) = this.(p{indx});
end

allSpecs = this.AllSpecs; 

for indx = 1:length(allSpecs)
    f = strrep(class(allSpecs(indx)), '.', '_');
    c.(f) = getstate(allSpecs(indx));
end

this.CapturedState = c;

% [EOF]
