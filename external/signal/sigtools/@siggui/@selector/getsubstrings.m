function strs = getsubstrings(hSct, tag)
%GETSUBSTRINGS Returns the labels for the subselection

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,2);

if nargin == 1, tag = get(hSct,'Selection'); end

if isempty(tag)
    strs = {''};
    return
end

strings    = get(hSct, 'Strings');
selections = getallselections(hSct);

% Find the referenced selection, use strmatch for partial string completion
indx = strmatch(tag, selections);

switch length(indx)
case 0
   error(message('signal:siggui:selector:getsubstrings:SelectionNotFound'))
case 1
    selections = get(hSct, 'Identifiers');
    
    % There are only substrings if the strings at indx are a cell
    if iscell(strings{indx})
        strs = strings{indx}(1:end);
        
        % If the length of the strings and tags are the same the first
        % string is the radio label, do no return it.
        if ~difference(hSct, indx)
            strs = strs(2:end);
        end
    else
        strs = {};
    end    
otherwise
    matches = [];
    for i = 1:length(indx)
        matches = [matches char(9) '''' selections{indx(i)} '''']; %#ok<AGROW>
    end
    error(message('signal:siggui:selector:getsubstrings:SelectionNotSpecific', matches));    
end

% [EOF]
