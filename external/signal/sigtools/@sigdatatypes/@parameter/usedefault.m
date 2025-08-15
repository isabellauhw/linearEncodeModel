function usedefault(hPrm, tool)
%USEDEFAULT Use the default parameter
%   USEDEFAULT(H, TOOL) Use the default parameters from TOOL's group.
%
%   See also MAKEDEFAULT.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

prefs = [];
if ispref('SignalProcessingToolbox', 'DefaultParameters')
    prefs = getpref('SignalProcessingToolbox', 'DefaultParameters');
end

if isfield(prefs, tool)
    struct2param(hPrm, prefs.(tool));
end

% [EOF]
