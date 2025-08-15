function editadditionalparameters(h)
%EDITADDITIONALPARAMETERS Allows access to the additional parameters

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Find all properties with a description
[props, descs] = getbuttonprops(h);

% Get default answers
answers = get(h, props);
if ~isa(answers, 'cell')
    answers = {answers};
end

% Build an input dialog out of the additional parameters
newvals = inputdlg(getTranslatedStringcell('signal:sigtools:siggui', descs) ,...
    getString(message('signal:sigtools:siggui:SetAdditionalParameters')), ...
    1, answers);

% If newvals is empty, the user pressed cancel, don't change value
if ~isempty(newvals)
    
    if ~iscell(props)
        props = {props};
    end

    c = {props{:}; newvals{:}};
    set(h, c{:});
    
    % Send a modified event
    send(h, 'UserModifiedSpecs', handle.EventData(h, 'UserModifiedSpecs'));
end

% [EOF]
