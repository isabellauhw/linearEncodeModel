function validate(h,specs)
%VALIDATE   Perform algorithm specific spec. validation.

%   Copyright 1999-2017 The MathWorks, Inc.

if rem(specs.FilterOrder,2)
    error(message('signal:fmethod:cheby1bp:validate:invalidSpec'));
end

% [EOF]
