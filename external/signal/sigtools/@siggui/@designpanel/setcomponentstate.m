function setcomponentstate(hObj, s, hindx)
%SETCOMPONENTSTATE Set the state of a single component

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(3,3);

if isempty(s), return; end

% If 'Components' exists we have a new state
if isfield(s, 'Components')
    
    if isa(hindx, 'siggui.selector') && ...
            any(strcmpi(get(hindx, 'Name'), {'response type', 'design method'}))
        return;
    end
    
    indx = findCellIndx(s.Components, get(hindx, 'Tag'));
    if ~isempty(indx)
        setstate(hindx, s.Components{indx});
    end
else
    
    % If there is a convertstatestruct method, use it.
    if ismethod(hindx, 'convertstatestruct')
        sindx = convertstatestruct(hindx, s);
        if ~isempty(sindx)
            setstate(hindx, sindx);
        end
    end
end

% -------------------------------------------------------------
function indx = findCellIndx(s, tag)

if isempty(tag), indx = []; return; end

indx = 1;
while indx <= length(s) && ~strcmpi(s{indx}.Tag, tag)
    indx = indx+1;
end

if indx > length(s)
    indx = [];
end

% If we didn't find anything, make sure it wasn't because of a name change.
if isempty(indx) && strcmpi(tag, 'siggui.firceqripinvsincoptsframe')
    indx = findCellIndx(s, 'siggui.firceqripoptsframe');
    
    % Make sure its the old state
    if ~isempty(indx) && ~isfield(s{indx}, 'invSincFreqFactor')
        indx = [];
    end
end

% [EOF]
