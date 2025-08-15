classdef (Abstract) abstractlppass < fspecs.abstractspecwithordnfs
%ABSTRACTSPECWITHORDNFS   Construct an ABSTRACTSPECWITHORDNFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlppass class
%   fspecs.abstractlppass extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstractlppass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlppass methods:
%       props2normalize -   Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS Property is of type 'posdouble user-defined' 
    Fpass = .4;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods 
        function set.Fpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass');
        value = double(value);
        obj.Fpass = value;
        end

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = props2normalize(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    c = cparam(h)
end  % possibly private or hidden 

end  % classdef

