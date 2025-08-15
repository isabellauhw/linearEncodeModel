classdef (Abstract) abstractlpstopfpass < fspecs.abstractlpstop
%ABSTRACTLPSTOPFPASS   Construct an ABSTRACTLPSTOPFPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlpstopfpass class
%   fspecs.abstractlpstopfpass extends fspecs.abstractlpstop.
%
%    fspecs.abstractlpstopfpass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Fpass - Property is of type 'double'  
%
%    fspecs.abstractlpstopfpass methods:
%       props2normalize -   Return the property name to normalize.
%       propstoadd -   Return the proeprties to add.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS Property is of type 'double' 
    Fpass = .45;
end


    methods 
        function set.Fpass(obj,value)
            % DataType = 'double'
        validateattributes(value,{'numeric'}, {'scalar'},'','Fpass')
        value = double(value);
        obj.Fpass = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = props2normalize(this)
    p = propstoadd(this)
end  % public methods 

end  % classdef

