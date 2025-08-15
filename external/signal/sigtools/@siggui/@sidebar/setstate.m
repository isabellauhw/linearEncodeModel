function setstate(hSB,state)
%SETSTATE Sets the state of sidebar.
%   SETSTATE(hSB, STATE) Sets the state of the sidebar associated with
%   hSB.  This state is all the information necessary to recreate the
%   current state of the sidebar object.
%
%   See also GETSTATE.

%   Copyright 1988-2017 The MathWorks, Inc.

hFig      = get(hSB,'FigureHandle');

p_state = []; %#ok<NASGU>

% Set the current panel
index = string2index(hSB, state.currentpanel);
set(hSB,'CurrentPanel',index);

names = fieldnames(rmfield(state,'currentpanel'));

% Make sure that we set the Input Processing widget of a pole-zero panel to
% inherited if coming from a pre R2011b block. We know that a block is pre
% R2011b because state.currentpanel = 'pzeditor' but no pzeditor field
% exists in the state structure.
if strcmp(state.currentpanel,'pzeditor') && ~isfield(state,'pzeditor')
  names{end+1} = 'pzeditor';
  hPanel = getpanelhandle(hSB, 'pzeditor');
  hPanel.InputProcessing = 'Inherited (this choice will be removed - see release notes)';
  state.pzeditor = getstate(hPanel);  
end

for i = 1:length(names)
    try
        hPanel = getpanelhandle(hSB, names{i});
    catch ME 
    end
    % If GETPANELHANDLE returned 0, then the panel does not exist
    if ~isequal(hPanel,0)
        if isempty(hPanel)
            hPanel = constructAndSavePanel(hSB, names{i});
        end
        
        % If the panel information is a structure, its fields contain function handles.
        % xxx
        if isstruct(hPanel)
            p_state = getfield(state, names{i});
            feval(hPanel.setstate, hFig, p_state);
        else
            p_state = getfield(state, names{i});
            setstate(hPanel, p_state);
        end
        
    % If GETPANELHANDLE errored because of unknown fields in structure (i.e. panels), warn
    elseif contains(lower(ME.message), ...
            sprintf('tag does not match any currently installed panels.'))
        warning(message('signal:siggui:sidebar:setstate:GUIWarn'));
    end
end

% [EOF]
