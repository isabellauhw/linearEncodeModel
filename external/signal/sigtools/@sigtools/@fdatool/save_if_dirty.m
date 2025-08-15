function status = save_if_dirty(hFDA, action)
% SAVE_IF_DIRTY Query the user to save if GUI is dirty.
%
% Inputs:
%     hFDA - handle to FDATool
%     action - 'closing', or 'loading' file.
% Output:
%     status = 1 if Yes, No, or UIs not dirty.
%     status = 0 if Cancel.
%

%   Author(s): P. Pacheco, R. Losada, P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

% This should be a private method

if ~hFDA.FileDirty
    status = 1;       % Proceed as normal
    return
end

% Removes the path and any extension
[path, file] = fileparts(get(hFDA, 'FileName'));

% If changes have not been saved, warn (prompt) user

if strcmp(action,'closing')
    ansBtn = questdlg(getString(message('signal:sigtools:sigtools:SaveSessionBeforeClosing',file)),'FDATool','Cancel');
elseif strcmp(action,'loading')
    ansBtn = questdlg(getString(message('signal:sigtools:sigtools:SaveSessionBeforeLoading',file)),'FDATool','Cancel');
end

switch ansBtn
case 'Yes'
    status = save(hFDA);
case 'No'
    status = 1;
    % User didn't save, reset dirty flag so opened file is not dirty
    hFDA.FileDirty = 0;
otherwise %case 'Cancel' or window is closed using from the frame
    status = 0;
end

% [EOF]
