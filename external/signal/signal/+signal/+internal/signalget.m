function varargout = signalget(obj,prop)
% GET    Get System object properties.
%   V = GET(obj, 'PropertyName') returns the value of the specified
%   property for the System object, obj.  If 'PropertyName' is
%   replaced by a cell array of strings containing property names,
%   GET returns a 1-by-N cell array of values. If obj is a vector of
%   objects, GET will return an M-by-1 cell array of values.
%
%   S = GET(obj) returns a structure in which each field name is the
%   name of a property of obj and each field contains the value of
%   that property.

if nargin > 1
    if ~ischar(prop) && ~iscellstr(prop) && ~isstring(prop)
        % throw same error as built-in get
        matlab.system.internal.error('signal:filterdesignerbase:invalidArgGet');
    end
    prop = convertStringsToChars(prop);
end

if nargin == 1
    % S = get(obj)
    % this 'get' bypasses the hidden prop warning (by spec choice)
    
    %Get information about property values only supported for a scalar object
    if numel(obj)~=1
        matlab.system.internal.error('MATLAB:class:MustBeScalarObject')
    end
    names = fieldnames(obj);
    for ii = 1:length(names)
        out.(names{ii}) = obj.(names{ii});
    end
    if length(names) < 1
        out = struct([]);
    end
    
    varargout = {out};
else
    %Add support for vector of strings (OR is string vector)
    if iscell(prop) || (isstring(prop) && ~isscalar(prop))
        % S = get(obj,<cell array of props>)       
        len = length(prop);
        out = cell(numel(obj),len);
        for oi = 1:numel(obj)
            for ii = 1:len
                %validatestring is used to enable case-insensitive and incomplete
                %propery name support needed for backwards compatibility when
                %convering from UDD to MCOS
                try
                    nprop = validatestring(prop{ii},fieldnames(obj(oi)));
                catch
                    nprop = prop{ii};
                end
                out{oi,ii} = obj(oi).(nprop);
            end
        end
        varargout = {out};
    else
        % S = get(obj,prop)
        out = cell(numel(obj),1);
        for oi = 1:numel(obj)
            try
                nprop = validatestring(prop,fieldnames(obj(oi)));
            catch
                nprop = prop;
            end
            out{oi,1} = obj(oi).(nprop);
        end
        
        if numel(out) == 1
            varargout = out;
        else
            varargout = {out};
        end
    end
end
end