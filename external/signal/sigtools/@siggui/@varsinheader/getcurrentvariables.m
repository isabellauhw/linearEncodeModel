function vars = getcurrentvariables(hVars)
%GETCURRENTVARIABLES Returns the variable names for the specified filter

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This might be able to be private.  The callbacks need this function

% Return the variables for the currently selected filter type
field = get(hVars, 'CurrentStructure');
if isfield(hVars.VariableNames, field)
    vars  = getfield(hVars.VariableNames, field);
else
    vars = {};
end

% [EOF]
