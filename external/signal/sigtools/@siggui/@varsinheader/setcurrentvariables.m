function setcurrentvariables(hVars, vars)
%SETCURRENTVARIABLES Sets the variable names for the specified filter
%   SETCURRENTVARIABLES(hVARS, VARS) Sets the variable names for the
%   specified filter in hVARS to VARS.  VARS must be a structure with
%   2 fields ('var' & 'length').  These fields must contains a cell array
%   of 2 strings.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This might be able to be a private method.

field = get(hVars, 'CurrentStructure');

if isfield(hVars.VariableNames, field)
    
    % Set the fields of the structure with the input variables
    vars  = setfield(hVars.VariableNames, field, vars);
    set(hVars, 'VariableNames', vars);
else
    error(message('signal:siggui:varsinheader:setcurrentvariables:NotSupported'));
end

% Announce that new variables have been specified.
send(hVars, 'NewVariables', handle.EventData(hVars, 'NewVariables'));

% [EOF]
