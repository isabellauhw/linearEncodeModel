classdef (Abstract) abstract3db < fspecs.abstractspecwithordnfs
%ABSTRACT3DB   Construct an ABSTRACT3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstract3db class
%   fspecs.abstract3db extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstract3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstract3db methods:
%       props2normalize -   Return the property name to normalize.


properties (AbortSet, SetObservable, GetObservable)
    %F3DB Property is of type 'posdouble user-defined' 
    F3dB = 0.5;
end


    methods 
        function set.F3dB(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','F3dB');
        value = double(value);
        obj.F3dB = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = props2normalize(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    c = cparam(h)
end  % possibly private or hidden 

end  % classdef

