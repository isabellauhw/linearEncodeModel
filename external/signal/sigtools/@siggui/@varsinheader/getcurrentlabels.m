function lbls = getcurrentlabels(hVars)
%GETCURRENTLABELS Returns the labels for the current filter type

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This can be private

% Return the labels of the currently selected filter type
field = get(hVars, 'CurrentStructure');
if isfield(hVars.Labels, field)
    lbls  = getfield(hVars.Labels, field);
else
    lbls  = {};
end

% [EOF]
