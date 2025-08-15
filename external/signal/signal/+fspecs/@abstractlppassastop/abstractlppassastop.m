classdef (Abstract) abstractlppassastop < fspecs.abstractlppass
%ABSTRACTLPPASSASTOP   Construct an ABSTRACTLPPASSASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlppassastop class
%   fspecs.abstractlppassastop extends fspecs.abstractlppass.
%
%    fspecs.abstractlppassastop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlppassastop methods:
%       magprops -   Return the magnitude properties.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods 
        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 

    methods  % public methods
    [pass,stop] = magprops(this)
end  % public methods 

end  % classdef

