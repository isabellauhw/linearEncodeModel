function reset(this)
%RESET   Reset the object.

%   Copyright 1999-2005 The MathWorks, Inc.

p = propstocopy(this);

p = [{'Specification'}, p];

c = this.CapturedState;

for indx = 1:length(p)
    this.(p{indx}) = c.(p{indx});
end

allSpecs = this.AllSpecs;

for indx = 1:length(allSpecs)
    f = strrep(class(allSpecs(indx)), '.', '_');
    setstate(allSpecs(indx), c.(f));
end

% [EOF]
