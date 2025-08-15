function state = getstate(hSB)
%GETSTATE Returns the state of sidebar.
%   GETSTATE(hSB) Returns the state of the sidebar associated with
%   hSB.  This state is all the information necessary to recreate
%   the current state of the sidebar object.
%
%   See also SETSTATE.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hFig      = get(hSB, 'FigureHandle');
labels    = get(hSB, 'Labels');

% Store the current panel
state.currentpanel = index2string(hSB,get(hSB,'CurrentPanel'));

% Loop through all the panels and store their information.
for i = 1:length(labels)
    
    hPanel = getpanelhandle(hSB, i);
    
    % If the index is invalid or if the Panel is empty do not get its state.
    if ~isequal(hPanel,0) & ~isempty(hPanel)
        
        % If the panel information is stored in a structure of function
        % handles FEVAL these function handles to get the state.
        % xxx
        if isstruct(hPanel)
            panel_state = feval(hPanel.getstate, hFig);
        else
            panel_state = getstate(hPanel);
        end
        
        if ~isempty(panel_state)
            state = setfield(state,labels{i},panel_state);
        end
    end
end

% [EOF]
