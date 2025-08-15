classdef (Abstract) abstractlpstopapass < fspecs.abstractlpstop
%ABSTRACTLPSTOPAPASS   Construct an ABSTRACTLPSTOPAPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlpstopapass class
%   fspecs.abstractlpstopapass extends fspecs.abstractlpstop.
%
%    fspecs.abstractlpstopapass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlpstopapass methods:
%       magprops -   Return the magnitude properties.
%       propstoadd -   Return the properties in the order they should be add.


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods 
        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

    end   % set and get functions 

    methods  % public methods
    [pass,stop] = magprops(this)
    p = propstoadd(this)
end  % public methods 

end  % classdef

