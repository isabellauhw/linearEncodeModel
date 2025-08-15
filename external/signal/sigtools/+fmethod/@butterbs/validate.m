function validate(h,specs)
%VALIDATE   Perform algorithm specific spec. validation.

%   Copyright 1999-2017 The MathWorks, Inc.

% Populate defaults
if rem(specs.FilterOrder,2)
    error(message('signal:fmethod:butterbs:validate:invalidSpec'));
end

% [EOF]
