function clean(this)
%CLEAN   Clean the grid.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

g = get(this, 'Grid');

[rows, cols] = size(g);

% Clean up any extra rows in the grid.
indx = rows;
while indx > 0 && all(isnan(g(indx,:)))
    g(indx,:) = [];
    indx      = indx-1;
end

indx = cols;
while indx > 0 && all(isnan(g(:,indx)))
    g(:,indx) = [];
    indx      = indx-1;
end

set(this, 'Grid', g);

% [EOF]
