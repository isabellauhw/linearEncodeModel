function varargout = signalset(obj,varargin)
%SET  Set object property values
%   SET(obj,'PropertyName',PropertyValue) sets the value of the
%   specified property for the object, obj. obj can be a vector of objects,
%   in which case SET sets the properties' values for all objects input.
%
%   SET(obj,'PropertyName1',Value1,'PropertyName2',Value2,...) sets
%   multiple property values with a single statement.
%
%   SET(obj,pn,pv) sets the named properties specified in the cell array of
%   strings, pn, to the corresponding values in the cell array, pv, for the
%   object, obj.  The cell arrays pn and pv must be 1-by-N
%
%   Given a structure S, whose field names are object property names,
%   SET(obj,S) sets the properties identified by each field name of S
%   with the values contained in the structure.
%
%   A = SET(obj, 'PropertyName') returns the possible values for the
%   specified property of the System object, obj. The returned array
%   is a cell array of possible value strings or an empty cell array
%   if the property does not have a finite set of possible string
%   values.
%
%   A = SET(obj) returns all property names and their possible values
%   for the object, obj. The return value is a structure whose
%   field names are the property names of obj, and whose values are
%   cell arrays of possible property value strings or empty cell
%   arrays.
%

%    Copyright 2015 The MathWorks, Inc.

switch(nargin)
    case 1
        % S = set(obj)
        nargoutchk(0,1);
        
        %Get information about property values only supported for a scalar object
        if numel(obj)~=1
            matlab.system.internal.error('MATLAB:class:MustBeScalarObject')
        end
        
        fns = fieldnames(obj);
        st = [];
        for ii = 1:length(fns)
            fn = fns{ii};
            fnprop = findprop(obj,fn);
            if ~isempty(fnprop) && strcmp(fnprop.SetAccess,'public')
                val = set(obj,fn);
                if isempty(val)
                    st.(fn) = {};
                else
                    st.(fn) = val;
                end
            end
        end
        varargout = {st};
    case 2
        % set(obj, struct)
        if isstruct(varargin{1})
            nargoutchk(0,0);
            
            st = varargin{1};
            stfn = fieldnames(st);
            
            for oi = 1:numel(obj)
                for ii = 1:length(stfn)
                    prop = stfn{ii};
                    %validatestring is used to enable case-insensitive and incomplete
                    %propery name support needed for backwards compatibility when
                    %convering from UDD to MCOS
                    try
                        nprop = validatestring(prop,fieldnames(obj(oi)));
                    catch
                        nprop = prop;
                    end
                    obj(oi).(nprop) = st.(prop);
                end
            end
        else
            %set(obj,'PropertyName')
            
            nargoutchk(0,1);
            
            %Get information about property values only supported for a scalar object
            if numel(obj)~=1
                matlab.system.internal.error('MATLAB:class:MustBeScalarObject')
            end
            
            try
                prop = validatestring(varargin{1},fieldnames(obj));
            catch
                prop = varargin{1};
            end
            mp = findprop(obj,prop);
            if isempty(mp)
                matlab.system.internal.error(...
                    'signal:sigtools:invalidProperty', prop, class(obj));
            elseif ~strcmp(mp.SetAccess, 'public')
                matlab.system.internal.error(...
                    'signal:sigtools:propertyInvalidSetAccess', prop, class(obj));
            end
            varargout = {getAllowedStringValues(obj,prop)};
            if isempty(varargout)
                varargout = {{}};
            end
        end
    otherwise
        % set(obj, <PV Pairs>)
        
        nargoutchk(0,0);
        
        if iscell(varargin{1})
            if length(varargin)~=2 || (length(varargin{1}) ~= length(varargin{2}))
                error(message('signal:sigtools:invalidPvp'));
            end
            
            len = length(varargin{1});
            for oi = 1:numel(obj)
                for ii = 1:len
                    try
                        prop = validatestring(varargin{1}{ii},fieldnames(obj(oi)));
                    catch
                        prop = varargin{1}{ii};
                    end
                    obj(oi).(prop) =  varargin{2}{ii};
                end
            end
        else
            
            if mod(length(varargin),2)
                error(message('signal:sigtools:invalidPvp'));
            end
            for oi = 1:numel(obj)
                for ii = 1:2:length(varargin)
                    % Set the property - if the property is protected or private, the set
                    % will error out (as desired) as this function is outside the class.
                    try
                        prop = validatestring(varargin{ii},fieldnames(obj(oi)));
                    catch
                        prop = varargin{ii};
                    end
                    obj(oi).(prop) =  varargin{ii+1};
                end
            end
        end
end
end