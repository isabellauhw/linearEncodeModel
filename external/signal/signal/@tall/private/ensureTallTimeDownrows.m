function ensureTallTimeDownrows(timeDimension, isInput)
% Ensure that TIMEDIMENSION is set to 'downrows' for tall arrays. Throw a
% comprehensive error from the tall message catalog.

%   Copyright 2019 The MathWorks, Inc.

narginchk(2, 2);

if timeDimension ~= "downrows"
    if isInput
        error(message('signal:tall:InputTimeDimensionMustBeDownrows'));
    else
        error(message('signal:tall:OutputTimeDimensionMustBeDownrows'));
    end
end