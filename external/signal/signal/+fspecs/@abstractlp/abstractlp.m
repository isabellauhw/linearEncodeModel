classdef (Abstract) abstractlp < fspecs.abstractspecwithordnfs
%ABSTRACTLP   Construct an ABSTRACTLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlp class
%   fspecs.abstractlp extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstractlp properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlp methods:
%       props2normalize -   Properties to normalize frequency.
%       thisvalidate -   Validate this object.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS Property is of type 'posdouble user-defined' 
    Fpass = 0.45;
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = 0.55;
end


    methods 
        function set.Fpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass');
        value = double(value);
        obj.Fpass = value;
        end

        function set.Fstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop');
        value = double(value);
        obj.Fstop = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = props2normalize(h)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 

end  % classdef

