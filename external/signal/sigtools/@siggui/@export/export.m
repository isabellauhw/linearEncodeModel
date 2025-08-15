function hXP = export(variables, labels, names, varargin)
%EXPORT Create an Export Object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(3,7);

% All inputs must be the same length at creation.
if length(variables) ~= length(labels) | length(variables) ~= length(names)
    error(message('signal:siggui:Export1:Export:InvalidDimensions'));
end

hXP = siggui.export;

set(hXP, 'ExportTarget', 'Workspace');
set(hXP, 'Variables', variables);
set(hXP, 'Labels', labels);
set(hXP, 'TargetNames', names);
set(hXP, 'VariableCount', length(variables));
set(hXP, 'Version', 1.0);

if nargin > 3, set(hXP, 'Objects', varargin{1}); end
if nargin > 4, set(hXP, 'ObjectLabels', varargin{2}); end
if nargin > 5, set(hXP, 'ObjectTargetNames', varargin{3}); end

% [EOF]
