function setgroup(hSct, varargin)
%SETGROUP Change a group in the selector
%   SETGROUP(hSCT, TAG, NEWTAGS, NEWSTRS) Change a popupmenu group in the selector
%   which is identified by TAG.  NEWTAGS stores the new identifiers for the selections
%   within the popup and NEWSTRS stores the new strings for the selections within the
%   popup.  Only subselections can be changed through this method.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Parse and validate the inputs
[tag, tags, strings] = parse_inputs(hSct, varargin{:});

selections = getallselections(hSct);
indx       = strmatch(tag, selections);

switch length(indx)
case 0
  error(message('signal:siggui:selector:setgroup:SelectionNotAvailable'));
case 1
    alltags    = get(hSct, 'Identifiers');
    allstrings = get(hSct, 'Strings');
    
    if iscell(alltags{indx})
        indx2   = find(strcmpi(hSct.SubSelection, alltags{indx}(2:end)))-difference(hSct, indx)+1;
        if isempty(indx2)
            cstring = '';
        else
            cstring = allstrings{indx}{indx2};
        end
        
    else
        cstring = '';
    end
    % Make sure that the radio button label is not being changed
    
    % If the tags and indexes are of the same size, then we want to retain
    % the first string (the label to the radio button)
    if ~difference(hSct, indx)
        if iscell(allstrings{indx})
            newstr = [allstrings{indx}(1) strings];
        else
            newstr = [{allstrings{indx}} strings];
        end
    else
        newstr = strings;
    end
    
    if iscell(alltags{indx})
        alltags{indx} = [alltags{indx}(1) tags];
    else
        if length(tags) == length(strings)
            alltags{indx} = [{alltags{indx}} tags];
        else
            alltags{indx} = tags;
        end
    end
    
    allstrings{indx} = newstr;
otherwise
    matches = [];
    for i = 1:length(indx)
        matches = [matches '  ''' selections{indx(i)} '''']; %#ok<AGROW>
    end
    error(message('signal:siggui:selector:setgroup:SelectionNotSpecific', matches));

end

set(hSct, 'Identifiers', alltags);
set(hSct, 'Strings', allstrings);

% Make sure that the subselection is still valid.
if strcmpi(hSct.Selection, tag)
    subselect = get(hSct, 'SubSelection');
    if isempty(find(strcmpi(subselect, tags), 1))
        
        % Make sure the string is unavailable too.
        cindx = find(strcmpi(cstring, allstrings{indx}));
        if isempty(cindx)
            set(hSct, 'subselection', tags{1});
        else
            
            % If the string is still available use it.
            set(hSct, 'subselection', alltags{indx}{cindx});
        end
    end
end

if isrendered(hSct)
    update(hSct, 'update_popup');
end


% ---------------------------------------------------------------------
function [tag, tags, strs] = parse_inputs(hSct, varargin)

narginchk(4,4);

tag  = varargin{1};
tags = varargin{2};
strs = varargin{3};

validate_inputs(tags, strs);

% --------------------------------------------------------------------
function validate_inputs(tags, strs)

if ~any(length(tags)-length(strs) == [0 1])
    error(message('signal:siggui:selector:setgroup:SigErr'));
end

% [EOF]
