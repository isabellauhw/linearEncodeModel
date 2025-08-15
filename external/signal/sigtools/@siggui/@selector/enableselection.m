function enableselection(hObj, varargin)
%ENABLESELECTION Enable a selection
%   ENABLESELECTION(hObj, TAG) Enable the disabled selection associated with TAG.
%
%   ENABLESELECTION(hObj, TAG1, TAG2, etc) Enable the disabled selections.
%
%   ENABLESELECTION(hObj) Enable all disabled selections.
%
%   See also DISABLESELECTION, SETGROUP.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,inf);

if nargin == 1
    dSelects = {};
    set(hObj, 'DisabledSelections', dSelects);

    % Verify that a selection is made
    check_selection(hObj);
    if isrendered(hObj)
        update(hObj, 'update_popup');
    end
else
    
    % Get the indexes to enable.
    indx = find_enabled_indexes(hObj, varargin{:});
    
    % Update the disabledselections
    dSelects = get(hObj, 'DisabledSelections');
    
    if ~isempty(indx)
        dSelects(indx) = [];
    
        set(hObj, 'DisabledSelections', dSelects);

        % Verify that a selection is made
        check_selection(hObj);
        if isrendered(hObj)
            update(hObj, 'update_popup');
        end
    end
end


% -------------------------------------------------------------------
function indx = find_enabled_indexes(hObj, varargin)

% Get the currently disabled selections.
dSelects = get(hObj, 'DisabledSelections');
indx     = [];

for i = 1:length(varargin)
    
    % Verify that the input is a disabled selection
    tag      = varargin{i};
    tempindx = strmatch(tag, dSelects);
    
    switch length(tempindx)
    case 0
        selections = getallselections(hObj);
        
        % Check against all the selections to create a good message.
        if isempty(strmatch(tag, selections))
            error(message('signal:siggui:selector:enableselection:SelectionNotAvailable'))
        else
            tempindx = [];
        end
    case 1
        % NO OP
    otherwise
        
        % Input is too vague
        matches = [];
        for ii = 1:length(tempindx)
            matches = [matches '  ''' dSelects{tempindx(ii)} '''']; %#ok<AGROW>
        end        
        error(message('signal:siggui:selector:enableselection:SelectionNotSpecific', matches))
    end
    
    if ~isempty(tempindx)
        indx(end+1) = tempindx;
    end
end

% ---------------------------------------------------------------------------
function check_selection(hObj)

% If there is no selection (because they were all disabled), select the first
if isempty(hObj.Selection)
    eSelects = getenabledselections(hObj);
    set(hObj, 'Selection', eSelects{1});
end

% [EOF]
