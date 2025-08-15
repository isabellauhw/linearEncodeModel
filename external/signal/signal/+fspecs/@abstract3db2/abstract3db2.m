classdef (Abstract) abstract3db2 < fspecs.abstractspecwithordnfs
%ABSTRACT3DB2   Construct an ABSTRACT3DB2 object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstract3db2 class
%   fspecs.abstract3db2 extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstract3db2 properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstract3db2 methods:
%       props2normalize -   Return the property name to normalize.


properties (AbortSet, SetObservable, GetObservable)
    %F3DB1 Property is of type 'posdouble user-defined' 
    F3dB1 = 0.4;
    %F3DB2 Property is of type 'posdouble user-defined' 
    F3dB2 = 0.6;
end


    methods 
        function set.F3dB1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','F3dB1');
        value = double(value);
        obj.F3dB1 = value;
        end

        function set.F3dB2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','F3dB2');
        value = double(value);
        obj.F3dB2 = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = props2normalize(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    c = cparam(h)
end  % possibly private or hidden 

end  % classdef

