function deletewarndlgs(hObj)
%DELETEWARNDLGS Delete warning dialogs

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(hObj, 'Handles');

if isfield(h, 'warn') && ~isempty(h.warn)
    hwarn = h.warn(ishghandle(h.warn));
    delete(hwarn);
    h.warn = [];
    set(hObj, 'Handles', h);
end

% [EOF]
