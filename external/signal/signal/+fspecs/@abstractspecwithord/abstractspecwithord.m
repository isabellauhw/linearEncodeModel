classdef (Abstract) abstractspecwithord < fspecs.abstractspec
%ABSTRACTSPECWITHORD   Construct an ABSTRACTSPECWITHORDSD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractspecwithord class
%   fspecs.abstractspecwithord extends fspecs.abstractspec.
%
%    fspecs.abstractspecwithord properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  


properties (AbortSet, SetObservable, GetObservable)
    %FILTERORDER Property is of type 'posint user-defined' 
    FilterOrder = 10;
end


    methods 
        function set.FilterOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','FilterOrder');    
        obj.FilterOrder = value;
        end

    end   % set and get functions 
end  % classdef

