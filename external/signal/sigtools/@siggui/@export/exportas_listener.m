function exportas_listener(hObj, eventData)
%EXPORTAS_LISTENER Listener to the exportas property

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(hObj, 'Handles');

strs = set(hObj, 'ExportTarget');
if iscoeffs(hObj)
    set(h.apopup, 'Value', 1);
    vcount = max([length(hObj.Labels), length(hObj.TargetNames), ...
            length(hObj.Variables)]);
else
    set(h.apopup, 'Value', 2);
    vcount = max([length(hObj.ObjectLabels), ...
            length(hObj.ObjectTargetNames), ...
            length(hObj.Objects)]);
    strs(2) = [];
    if strcmpi(get(hObj, 'ExportTarget'), 'Text-file')
        set(hObj, 'ExportTarget', 'Workspace');
    end
end

set(h.popup, 'String', strs);

tcount = max([length(hObj.Labels), length(hObj.TargetNames), ...
        length(hObj.Variables), length(hObj.ObjectLabels), ...
        length(hObj.ObjectTargetNames), length(hObj.Objects)]);

set(hObj, 'VariableCount', tcount);

update_editboxes(hObj);
update_labels(hObj);

set(hObj, 'IsApplied', 0);

% [EOF]
