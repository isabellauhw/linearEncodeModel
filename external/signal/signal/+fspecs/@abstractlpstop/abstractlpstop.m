classdef (Abstract) abstractlpstop < fspecs.abstractspecwithordnfs
%ABSTRACTLPSTOP   Construct an ABSTRACTLPSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlpstop class
%   fspecs.abstractlpstop extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstractlpstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlpstop methods:
%       props2normalize -   Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = 0.5;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods 
        function set.Fstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop');
        value = double(value);
        obj.Fstop = value;
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
    p = props2normalize(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [p,s] = magprops(this)
end  % possibly private or hidden 

end  % classdef

