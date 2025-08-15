function update_editboxes(hObj)
%UPDATE_EDITBOXES Update the export edit boxes

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This can be a private method

h = get(hObj, 'Handles');

if ~ishghandle(h.edit(1))
    render_editboxes(hObj);
    return;
end

if iscoeffs(hObj)
    eNames = get(hObj, 'TargetNames');
else
    eNames = get(hObj, 'ObjectTargetNames');
end

% Sync the targetnames with the strings in the editboxes
for i = 1:length(eNames)
    set(h.edit(i),'String', eNames{i}, 'Visible', 'On');
end

set(h.edit(length(eNames)+1:length(h.edit)), 'Visible', 'Off');

% [EOF]
