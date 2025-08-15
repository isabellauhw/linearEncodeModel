function rcvals = refvals(this)
%REFVALS   Reference coefficient values.
%This should be a private method.
%   The values are returned in a cell array.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.

rcnames = refcoefficientnames(this);
rcvals = cell(size(rcnames));
for ii = 1:length(rcvals)
    rcvals{ii} = this.(rcnames{ii});
end

% [EOF]