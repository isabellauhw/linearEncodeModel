function eSelects = getenabledselections(hSct)
%GETENABLEDSELECTIONS Returns the selections which are not disabled

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This can be a private method

selects  = getallselections(hSct);
dSelects = get(hSct, 'DisabledSelections');

eSelects = {};

% Loop over the selections and find those which are enabled
for i = 1:length(selects)
    if isempty(strmatch(selects{i}, dSelects))
        eSelects{end+1} = selects{i};
    end
end

% [EOF]
