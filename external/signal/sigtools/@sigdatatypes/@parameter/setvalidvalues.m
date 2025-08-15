function setvalidvalues(hPrm, vv)
%SETVALIDVALUES Change the valid values
%   SETVALIDVALUES(hPRM, VV) Change the valid values to VV.  This method works
%   only for parameters that store a cell of strings for their valid values.
%   The valid value vector must remain the same length.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

% The function only applies if the old and new valid values are cells of strs
if ~iscellstr(vv)
    error(message('signal:sigdatatypes:parameter:setvalidvalues:NewValuesMustBeAString'));
end

oldvv = get(hPrm, 'AllOptions');
if ~iscellstr(oldvv)
    error(message('signal:sigdatatypes:parameter:setvalidvalues:OldValuesMustBeAString'));
end
oldvv = {oldvv{:}};

if length(oldvv) ~= length(vv)
    error(message('signal:sigdatatypes:parameter:setvalidvalues:InvalidDimensions'));
end

if ~isequal(oldvv, vv)

    p = findprop(hPrm, 'Value');

    indx = find(strcmpi(hPrm.Value, oldvv));
    dindx = find(strcmpi(hPrm.DefaultValue, oldvv));
    
    delete(p);

    set(hPrm, 'AllOptions', vv);

    createvaluefromcell(hPrm);

    set(hPrm, 'Value', vv{indx});
    set(hPrm, 'DefaultValue', vv{dindx});

    send(hPrm, 'NewValidValues', handle.EventData(hPrm, 'NewValidValues'));
end

% [EOF]
