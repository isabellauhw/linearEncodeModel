function s = designopts(this, designmethod)
%DESIGNOPTS   Return information about the design options.

%   Copyright 2008-2018 The MathWorks, Inc.

if nargin > 1
    designmethod = convertStringsToChars(designmethod);
end

s = designopts(this.PulseShapeObj, designmethod);

% [EOF]
