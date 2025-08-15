classdef (Abstract) abstractlpmin < fspecs.abstractspecwithfs
%ABSTRACTSPECWITHFS   Construct an ABSTRACTSPECWITHFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlpmin class
%   fspecs.abstractlpmin extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractlpmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlpmin methods:
%       magprops -   Returns the passband and stopband magnitude properties.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs.
%       thisvalidate -   Checks if this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS Property is of type 'posdouble user-defined' 
    Fpass = 0.45;
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = 0.55;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
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

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 

    methods  % public methods
    [p,s] = magprops(this)
    p = props2normalize(h)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 

end  % classdef

