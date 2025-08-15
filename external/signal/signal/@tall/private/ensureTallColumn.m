function x = ensureTallColumn(x)
% Ensure that X is a tall column vector. Throw a comprehensive error from
% the tall message catalog.

%   Copyright 2019 The MathWorks, Inc.

narginchk(1, 1);
nargoutchk(1, 1);

x = tall.validateColumn(x, message('signal:tall:TallInputMustBeColumn'));