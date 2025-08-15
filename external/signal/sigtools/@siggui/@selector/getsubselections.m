function subselects = getsubselections(hSct, tag)
%GETSUBSELECTIONS Returns all subselections for a given selection
%   GETSUBSELECTIONS(hSCT) Returns all subselections for the current selection
%
%   GETSUBSELECTIONS(hSCT, TAG) Returns all subselections for the selection
%   specified by the string TAG.

%   Copyright 1988-2017 The MathWorks, Inc.

% This can be a private method

narginchk(1,2);

identifiers = get(hSct, 'Identifiers');
selections  = getallselections(hSct);

if nargin == 1
    tag = get(hSct,'Selection');
end

if isempty(tag)
    subselects = {''};
    return
end

% Find the referenced selection
indx = strmatch(tag, selections);

switch length(indx)
case 0
    error(message('signal:siggui:selector:getsubselections:SelectionNotFound'))    
case 1
    if iscell(identifiers{indx})
        subselects = {identifiers{indx}{2:end}};
    else
        subselects = {};
    end    
otherwise
    matches = [];
    for i = 1:length(indx)
        matches = [matches char(9) '''' selections{indx(i)} '''']; %#ok<AGROW>
    end
    error(message('signal:siggui:selector:getsubselections:SelectionNotSpecific', matches))
end

% [EOF]
