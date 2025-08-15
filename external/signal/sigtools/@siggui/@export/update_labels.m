function update_labels(hObj)
%UPDATE_LABELS Update the labels in the Export Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This should be private

h    = get(hObj, 'Handles');

if ~ishghandle(h.labels(1))
    render_labels(hObj);
    return;
end

if iscoeffs(hObj)
    lbls = get(hObj, 'Labels');
else
    lbls = get(hObj, 'ObjectLabels');
end

% Sync the Labels
for i = 1:length(lbls)
    set(h.labels(i), 'String', lbls{i}, 'Visible', 'On');
end

set(h.labels(length(lbls)+1:length(h.labels)), 'Visible', 'Off');

% [EOF]
