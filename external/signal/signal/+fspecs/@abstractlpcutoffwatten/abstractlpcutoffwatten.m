classdef (Abstract) abstractlpcutoffwatten < fspecs.abstractlpcutoff
%ABSTRACTLPCUTOFFWATTEN   Construct an ABSTRACTLPCUTOFFWATTEN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlpcutoffwatten class
%   fspecs.abstractlpcutoffwatten extends fspecs.abstractlpcutoff.
%
%    fspecs.abstractlpcutoffwatten properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'double'  
%       Astop - Property is of type 'double'  


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'double' 
    Apass = 1;
    %ASTOP Property is of type 'double' 
    Astop = 60;
end


    methods 
        function set.Apass(obj,value)
            % DataType = 'double'
        validateattributes(value,{'numeric'}, {'scalar'},'','Apass')
        value = double(value);
        obj.Apass = value;
        end

        function set.Astop(obj,value)
            % DataType = 'double'
        validateattributes(value,{'numeric'}, {'scalar'},'','Astop')
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 
end  % classdef

