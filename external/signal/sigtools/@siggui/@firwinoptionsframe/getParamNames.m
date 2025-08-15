function paramNames = getParamNames(this)
%GETPARAMNAMES Get the paramNames.

%   Copyright 2008 The MathWorks, Inc.

if isa(this.privWindow, 'sigwin.functiondefined')
    paramNames = {'FunctionName', 'Parameter'};
else
    paramNames = getparamnames(this.privWindow);
end

if ~iscell(paramNames)
    paramNames = {paramNames ''};
elseif length(paramNames) == 1
    paramNames = {paramNames{1} ''};
end

% [EOF]
