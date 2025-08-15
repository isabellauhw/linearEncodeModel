classdef (Abstract) abstractlpcutoff < fspecs.abstractspecwithordnfs
%ABSTRACTLPCUTOFF   Construct an ABSTRACTLPCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlpcutoff class
%   fspecs.abstractlpcutoff extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstractlpcutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlpcutoff methods:
%       props2normalize -   Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FCUTOFF Property is of type 'posdouble user-defined' 
    Fcutoff = 0.5;
end


    methods 
        function set.Fcutoff(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fcutoff');
        value = double(value);
        obj.Fcutoff = value;
        end

    end   % set and get functions 

    methods  % public methods
    p = props2normalize(h)
end  % public methods 

end  % classdef

