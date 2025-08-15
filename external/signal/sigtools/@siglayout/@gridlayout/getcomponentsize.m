function [m, n] = getcomponentsize(this, indx, jndx)
%GETCOMPONENTSIZE   Get the componentsize.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

g = get(this, 'Grid');

h = g(indx, jndx);

if isnan(h)
    m = 0;
    n = 0;
else
    m = find(g(:, jndx) == h, 1, 'last' ) - indx + 1;
    n = find(g(indx,:) == h, 1, 'last' )  - jndx + 1;
end

if nargout < 2
    m = [m n];
end

% [EOF]
