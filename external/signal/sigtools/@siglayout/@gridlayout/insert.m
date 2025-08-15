function insert(this, type, indx)
%INSERT   Insert a row or a column at an index.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

g = get(this, 'Grid');

[rows, cols] = size(g);

switch lower(type)
    case 'row'
        g = [g(1:indx-1,:); NaN(1, cols); g(indx:end,:)];
    case 'column'
        g = [g(:, 1:indx-1) NaN(rows, 1) g(:, indx:end)];
end

set(this, 'Grid', g);

% [EOF]
