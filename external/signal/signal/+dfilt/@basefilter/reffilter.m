function Hd = reffilter(this)
%REFFILTER   Return the reference filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% Loop over and make a copy.
for indx = 1:length(this)
    Hd(indx) = thisreffilter(this(indx));
end

% [EOF]
