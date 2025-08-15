function varargout = setvalue(hPrm, value, event)
%SETVALUE Set the value of the object after error checking
%   SETVALUE(hPRM, VAL) Set the value of the object.  SETVALUE can accept
%   a vector of parameter objects as long as VAL is a cell array of the same
%   length.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin == 3 & strcmpi(event, 'noevent')
    event = false;
else
    event = true;
end

msg = '';

if nargin == 1
    varargout{1} = validvaluestring(hPrm);
    return;
end

errorindx = [];
if length(hPrm) > 1
    if ~iscell(value) | length(hPrm) ~= length(value)
        error(message('signal:sigdatatypes:parameter:setvalue:InvalidDimensions'));
    end
    
    msg = '';
    wasset = false;
    tags = {};
    for indx = 1:length(hPrm)
        [newmsg, newwasset] = lclsetvalue(hPrm(indx), value{indx});
        if newwasset
            tags{end+1} = hPrm(indx).Tag;
            wasset = true;
        end
        if ~isempty(newmsg)
            errorindx = [errorindx indx];
            msg = strvcat(msg, newmsg);
        end
    end
else
    tags = hPrm.Tag;
    [msg, wasset] = lclsetvalue(hPrm, value);
    if ~isempty(msg)
        errorindx = 1;
    end
end

if wasset && event
    % Sending multiple notice to each hPrm item 
    % to make sure the context menu could be noticed.
    for i=1:length(hPrm)
        send(hPrm(i), 'NewValue', ...
            sigdatatypes.sigeventdata(hPrm(i), 'NewValue', tags));
    end
end

if nargout
    varargout = {msg, errorindx};
else
    if ~isempty(msg), error(message('signal:sigdatatypes:parameter:setvalue:AllMessages',msg)); end
end


% ----------------------------------------------------------
function [msg, wasset] = lclsetvalue(hPrm, value)


valid   = get(hPrm, 'ValidValues');

% This is still necessary because we cannot send a vector of inputs to
% the checkfunction for a usertype
b = true;
msg = '';

if isa(valid, 'function_handle')
    try
        feval(valid, value);
    catch ME
        b = false;
        msg = ME.message; 
    end
elseif iscellstr(valid)
    
    % NO OP.  We'll let the set operation tell us if its valid.
    if isnumeric(value)
        value = valid{value};
    end
elseif isnumeric(valid)

    % Check the limits of valid values
    if value > valid(end)
        mssgObj = message('signal:sigdatatypes:parameter:setvalue:ValueTooLarge',...
          num2str(value), hPrm.Name, num2str(valid(end)));
        msg = getString(mssgObj);
        b = false;
    elseif value < valid(1)
        mssgObj = message('signal:sigdatatypes:parameter:setvalue:ValueTooSmall',...
          num2str(value), hPrm.Name, num2str(valid(1)));
        msg = getString(mssgObj);      
        b = false;
    % If there is a 3rd element, check the spacing of value.
    elseif length(valid) == 3 && ...
            sqrt(eps) < rem(value-valid(1), valid(2))          
        mssgObj = message('signal:sigdatatypes:parameter:setvalue:ValueNotValid',hPrm.Name);
        msg = getString(mssgObj);      
        b = false;
    elseif isnan(value)
        mssgObj = message('signal:sigdatatypes:parameter:setvalue:NaNNotValid',hPrm.Name);
        msg = getString(mssgObj);            
        b = false;
    end
end

if b && ~lcl_isequal(get(hPrm, 'Value'), value)

    wasset = true;
    set(hPrm, 'Value', value);
else
    wasset = false;
end

send(hPrm, 'ForceUpdate', ...
    sigdatatypes.sigeventdata(hPrm, 'ForceUpdate', value));

% -------------------------------------------------------------------------
function b = lcl_isequal(oldValue, newValue)

% Because we are converting from numerics to strings and back to numerics
% we will have some round off error. We need to use a tolerance check
% instead of simply checking that the numbers match exactly.
if isnumeric(oldValue)
    if all(size(oldValue) == size(newValue))
        variance = (oldValue-newValue)/mean(oldValue+newValue);
        if abs(mean(variance(:))) > 1e-6
            b = false;
        else
            b = true;
        end
    else
        b = false;
    end
else
    b = isequal(oldValue, newValue);
end

% [EOF]
