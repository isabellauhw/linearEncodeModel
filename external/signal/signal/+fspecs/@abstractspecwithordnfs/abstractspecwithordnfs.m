classdef (Abstract) abstractspecwithordnfs < fspecs.abstractspecwithfs
%ABSTRACTSPECWITHORDNFS   Construct an ABSTRACTSPECWITHORDNFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractspecwithordnfs class
%   fspecs.abstractspecwithordnfs extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractspecwithordnfs properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%
%    fspecs.abstractspecwithordnfs methods:
%       set_filterorder -   PreSet function for the 'filterorder' property.


properties (AbortSet, SetObservable, GetObservable)
    %FILTERORDER Property is of type 'posint user-defined' 
    FilterOrder = 10;
end


    methods 
        function set.FilterOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','FilterOrder');    
        obj.FilterOrder = set_filterorder(obj,value);
        end

    end   % set and get functions 

    methods  % public methods
    filterorder = set_filterorder(this,filterorder)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    s = aswofs_getdesignpanelstate(this)
end  % possibly private or hidden 

end  % classdef

