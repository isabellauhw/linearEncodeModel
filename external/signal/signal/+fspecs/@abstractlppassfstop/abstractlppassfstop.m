classdef (Abstract) abstractlppassfstop < fspecs.abstractlppass
%ABSTRACTLPPASSFSTOP   Construct an ABSTRACTLPPASSFSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractlppassfstop class
%   fspecs.abstractlppassfstop extends fspecs.abstractlppass.
%
%    fspecs.abstractlppassfstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractlppassfstop methods:
%       props2normalize -   Properties to normalize frequency.
%       thisvalidate -   Check that this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = .6;
end


    methods 
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


    methods (Hidden) % possibly private or hidden
    [p,s] = magprops(this)
    p = propstoadd(this)
end  % possibly private or hidden 

end  % classdef

