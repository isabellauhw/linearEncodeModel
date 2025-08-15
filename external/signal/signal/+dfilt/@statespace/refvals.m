function rcvals = refvals(this)
%REFVALS   Return the reference values.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

rcnames = refcoefficientnames(this);
rcvals = cell(size(rcnames));
for ii = 1:length(rcvals)
    rcvals{ii} = this.(rcnames{ii});
end
% [EOF]
